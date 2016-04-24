---
title: Parallel Execution Inside Scala for-comprehensions
author: Ionuț G. Stan
date: February 02, 2015
---

```fsharp
// Learn more about F# at http://fsharp.net

// Hindley Milner Type Inference Sample Implementation

// ************************************************
// AST
// ************************************************

type Literal
   = Char  of  char          // character literal
   | String of string        // string literal
   | Integer of  int         // integer literal
   | Float  of  float        // floating point literal

type Exp
    = Var      of string               // variable
    | Lam      of string * Exp         // lambda abstraction
    | App      of Exp * Exp            // application
    | InfixApp of Exp * string * Exp   // infix application
    | Let      of string * Exp * Exp   // local definition
    | Lit      of Literal              // literal

// ************************************************
// Type Tree
// ************************************************

type Type
    = TyLam of Type * Type
    | TyVar of string
    | TyCon of string * Type list
    with override this.ToString() =
            match this with
            | TyLam (t1, t2) -> sprintf "(%s -> %s)" (t1.ToString()) (t2.ToString())
            | TyVar a -> a
            | TyCon (s, ts) -> s

// ************************************************
// Subtitutions
// ************************************************

type Subst = Subst of Map<string, Type>

// extend: string -> Type -> Subst -> Subst
let extend v t (Subst s) = Subst (Map.add v t s)

// lookup: string -> Subst -> Type
let lookup v (Subst s) =
    if (Map.containsKey v s) then
        Map.find v s
    else
        TyVar v

// Apply a type substitution to a type
// subs: Type -> Subst -> Type
let rec subs t s =
    match t with
    | TyVar n ->
          let t1 = lookup n s
          if t = t1 then t1
          else subs t1 s
    | TyLam(a, r) ->
          TyLam(subs a s, subs r s)
    | TyCon(name, tyArgs) ->
            TyCon(name, tyArgs |> List.map (fun x -> subs x s))

// ************************************************
// Environments
// ************************************************

type TyScheme = TyScheme of Type * Set<string>

type Env = Env of Map<string, TyScheme>

// Calculate the list of type variables occurring in a type,
// without repeats
// getTVarsOfType: Type -> Set<string>
let rec getTVarsOfType t =
    match t with
    | TyVar n  -> Set.singleton n
    | TyLam(t1, t2) -> getTVarsOfType(t1) + getTVarsOfType(t2)
    | TyCon(_, args) ->
        List.fold (fun acc t -> acc + getTVarsOfType t) Set.empty args

// getTVarsOfScheme: TyScheme -> Set<string>
let getTVarsOfScheme (TyScheme (t, tvars)) =
    (getTVarsOfType t) - tvars

// getTVarsOfEnv: Env -> Set<string>
let getTVarsOfEnv (Env e) =
    let schemes = e |> Map.toSeq |> Seq.map snd
    Seq.fold (fun acc s -> acc + (getTVarsOfScheme s)) Set.empty schemes

// ************************************************************
// Unification
// ************************************************************

exception UnificationError of Type * Type

// Calculate the most general unifier of two types,
// raising a UnificationError if there isn't one
// mgu: Type -> Type -> Subst -> Subst
let rec mgu a b s =
    match (subs a s, subs b s) with
    | TyVar ta, TyVar tb when ta = tb -> s
    | TyVar ta, _ when not <| Set.contains ta (getTVarsOfType b) -> extend ta b s
    | _, TyVar _ -> mgu b a s
    | TyLam (a1, b1), TyLam (a2, b2) -> mgu a1 a2 (mgu b1 b2 s)
    | TyCon(name1, args1), TyCon(name2, args2) when name1 = name2 ->
            (s, args1, args2) |||> List.fold2 (fun subst t1 t2 -> mgu t1 t2 subst)
    | x,y -> raise <| UnificationError (x,y)

// ************************************************************
// State Monad
// ************************************************************

type State<'state, 'a> = State of ('state -> 'a * 'state)

let run (State f) s = f s

type StateMonad() =
    member b.Bind(State m, f) =
      State (fun s ->
               let (v,s') = m s in
               let (State n) = f v in n s')
    member b.Return x = State (fun s -> x, s)

    member b.ReturnFrom x = x

    member b.Zero () = State (fun s -> (), s)

    member b.Combine(r1, r2) = b.Bind(r1, fun () -> r2)

    member b.Delay f = State (fun s -> run (f()) s)



let state = StateMonad()

let getState = State (fun s -> s, s)
let setState s = State (fun _ -> (), s)

let execute m s = match m with
                  | State f -> let r = f s
                               match r with
                               |(x,_) -> x

let mmap f xs =
    let rec MMap' (f, xs', out) =
          state { match xs' with
                  | h :: t ->
                      let! h' = f(h)
                      return! MMap'(f, t, List.append out [h'])
                  | [] -> return out }
    MMap' (f, xs, [])

// ************************************************************
// Alpha converter (Converts T4, T5, T6 to 'a, 'b, 'c)
// ************************************************************

let getName k =
    let containsKey k = state { let! (map, id) = getState
                                return Map.containsKey k map }

    let addName k = state { let! (map, id) = getState
                            let newid = char (int id + 1)
                            do! setState(Map.add k id map, newid)
                            return () }

    state { let! success = containsKey k
            if (not success) then
                do! addName k
            let! (map, id) = getState
            return Map.find k map }

// renameTVarsToLetters: Type -> Type
let renameTVarsToLetters t =
    let rec run x =
        state {
                match x with
                | TyVar(name) ->
                    let! newName = getName name
                    return TyVar(sprintf "'%c" newName)
                | TyLam(arg, res) ->
                    let! t1 = run arg
                    let! t2 = run res
                    return TyLam(t1, t2)
                | TyCon(name, typeArgs) ->
                    let! list = mmap (fun x -> run x) typeArgs
                    return TyCon(name, list) }
    execute (run t) (Map.empty, 'a')

// ****************************************************************
// Calculate principal Type
// ****************************************************************

let newTyVar =
    state { let! x = getState
            do! setState(x + 1)
            return TyVar(sprintf "T%d" x) }

let integerCon = TyCon("int", [])
let floatCon = TyCon("float", [])
let charCon = TyCon("char", [])
let stringCon = TyCon("string", [])

let litToTy lit =
    match lit with
    | Integer _ -> integerCon
    | Float _ -> floatCon
    | Char _ -> charCon
    | String  _ -> stringCon

// Calculate the principal type scheme for an expression in a given
// typing environment
// tp: Env -> Exp -> Type -> Subst -> State<int, Subst>
let rec tp env exp bt s =
  let findSc n (Env e) = Map.find n e
  let containsSc n (Env e) = Map.containsKey n e
  let addSc n sc (Env e) = Env (Map.add n sc e)
  state {
        match exp with
        | Lit v ->
            return mgu (litToTy v) bt s
        | Var n ->
            if not (containsSc n env)
            then failwith "Name %s no found" n
            let (TyScheme (t, _)) = findSc n env
            return mgu (subs t s) bt s
        | Lam (x, e) ->
            let! a = newTyVar
            let! b = newTyVar
            let s1 = mgu bt (TyLam (a, b)) s
            let newEnv = addSc x (TyScheme (a, Set.empty)) env
            return! tp newEnv e b s1
        | App(e1, e2) ->
            let! a = newTyVar
            let! s1 = tp env e1 (TyLam(a, bt)) s
            return! tp env e2 a s1
        | InfixApp(e1, op, e2) ->
            let exp1 = App(App(Var op, e1), e2)
            return! tp env exp1 bt s
        | Let(name, inV, body) ->
            let! a = newTyVar
            let! s1 = tp env inV a s
            let t = subs a s1
            let newScheme = TyScheme (t, ((getTVarsOfType t) - (getTVarsOfEnv env)))
            return! tp (addSc name newScheme env) body bt s1 }

let predefinedEnv =
    Env(["+", TyScheme (TyLam(integerCon, TyLam(integerCon, integerCon)), Set.empty)
         "*", TyScheme (TyLam(integerCon, TyLam(integerCon, integerCon)), Set.empty)
         "-", TyScheme (TyLam(integerCon, TyLam(integerCon, integerCon)), Set.empty)
           ] |> Map.ofList)

// typeOf: Exp -> Type
let typeOf exp =
   let typeOf' exp =
    state { let! (a:Type) = newTyVar
            let emptySubst = Subst (Map.empty)
            let! s1 = tp predefinedEnv exp a emptySubst
            return subs a s1 }
   in execute (typeOf' exp) 0 |> renameTVarsToLetters

// ***********************************************************
// Example
// ***********************************************************

let composeAst = Let("compose",
                    Lam("f",
                        Lam("g",
                            Lam ("x",
                                App(Var "g", App(Var "f", Var "x"))))),
                        Var "compose")

let t = typeOf composeAst

printfn "%s" (t.ToString())
```

```scala
val response = for {
  data        <- obtainData
  longRunning  = dependsOnData(data)
  a           <- doStuff1
  b           <- doStuff2
  c           <- doStuff3
  d           <- longRunning
} yield {
  // do stuff with a, b, c and d
}
```
