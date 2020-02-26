```
docker build -t igstan.ro .
docker run --rm -itv "$PWD:/opt" -p 4000:4000 igstan.ro
```
