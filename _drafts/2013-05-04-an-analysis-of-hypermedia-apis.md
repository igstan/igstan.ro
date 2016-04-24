--------------------------------------------------------------------------------
title: An Analysis of Hypermedia APIs
author: Ionuț G. Stan
date: May 4, 2013
--------------------------------------------------------------------------------

For quite some time now I've been busy building the upcoming version of the API
for the [company][0] I work for, the [Shoeboxed API][1]. It's been quite a while
and we've almost finalized it. But the exposure to various blog posts and articles
I had while working on it, as well as the problems I encountered during this
period, made me think more about the latest trend in API design: Hypermedia APIs.
Is it worth it? In this blog post I will try to give myself an answer, but
raising a few pertinent questions that others would be kind enough to answer is
just as good a goal.

### Note
I tried as much as possible to make a coherent case on Hypermedia APIs, but this
post has been written during a period of a few weeks, in which new ideas and
observations emerged. You might find that some of the section don't really
follow a clear thought line. That's why.

The Domain Model
----------------
A few words about the company. Shoeboxed takes your documents as input and
extracts relevant data out of them. We accept and understand several formats,
including images or PDFs of scanned documents, email messages, HTML source of
web pages, and the most important one, postal envelopes full of real-world, paper
receipts. You give them to us and we extract the important data and make it
available to you in various ways, the primary one being our website.

But we also expose an API which offers some of the functionality of the website.
The current version, v1, is a pretty old, RPC-style, API using XML as the
transport format. In a way it's pretty similar to SOAP. It has a few quirks here
and there, but it does its job. However we wanted something better. Something
that would lower the entry barrier to new developers. Something that developers
would be eager to play with, write libraries and applications for.

These are the goals of the upcoming version. Developer friendliness and ease of
use. Another goal is ease of change, for us. We'd like to evolve the API as often
as needed without breaking old clients (providing a decent deprecation timeframe).

Shoeboxed API v2 Sneak Peek
---------------------------
The current incarnation of v2, whose docs I can't yet make public, is pretty
similar to the [GitHub API][2]. Basically, there are a few URLs that map to
the domain model's language. For example, retrieving a user's documents
translates to:

    GET /user/documents/

Similarly, uploading a document is achieved by POST-ing a multipart request to
"/user/documents". In the vast majority of cases we only support JSON for both
request and response bodies. For example, retrieving a user's list of categories
yields something like this:

    GET /user/categories/

~~~json
{
  "categories": [
    {
      "id": "1",
      "type": "system",
      "name": "category 001",
      "description": "description 001",
      "receipts": 5
    },
    {
      "id": "2",
      "name": "category 002",
      "type": "custom",
      "description": "description 002",
      "receipts": 2
    }
  ]
}
~~~

Creating a new category requires the API client to send us a JSON object:

    POST /user/categories/

~~~json
{
  "name": "category 003",
  "description": "description 003"
}
~~~

A successful response returns "201 Created" with the JSON representation of the
newly created category as the response body.

~~~json
{
  "id": "3",
  "name": "category 003",
  "type": "custom",
  "description": "description 003",
  "receipts": 0
}
~~~

Updating a category entails PUT-ing the modified properties at the URL formed
by appending the category ID to "/user/categories":

    PUT /user/categories/3/

~~~json
{
  "name": "modified category 003"
}
~~~

A successful response returns "204 No Content".


That's Blatantly Wrong!
-----------------------
Hypermedia aficionados will certainly have a few objections to raise by this time.
Why does the list of categories contain a category ID instead of a category URL.
Same with the response received after a successful creation of a category.
Furthermore, the response should include a `Location` header with the URL address
of the created resource.

In this blog post I won't try to argue against them, nor in favour of. I will
try, though, to see, using a quantitative approach, which of the two flows makes
more sense. I will try to understand what properties of the communication between
the API service and the client are quantifiable, and balance them at the end.
If all goes well, tomorrow I should wory less whether I'm doing the right thing,
or a move to a more Hypermedia approach is desirable.


Goals
-----
I mentioned balance above, but what am I trying to balance? There are three main
things:

 - the API clients should be simple to build
 - the API service should be simple to evolve
 - mistakes in communication flows should be as hard as possible to make

I like to think of this balance as a contact surface between the two entities,
the API client and the API server. The smaller the contact surface, the easier
the API service will be able to evolve without breaking existing clients. On the
other hand, a smaller contact surface might imply extra work for developers
building clients.

First of all, how do I know that API clients will be simple to build? Is there a
way I can quantify this? I don't have a clear view of this yet, but it seems the
more documentation you have to read, the harder it gets. As long as the API
relies on common knowledge, HTTP in this case, the easier it becomes to build an
integration. Also, the more hoops you have to jump to reach your goal, the
cumbersome it seems to get. For example, having to traverse a graph of links
to reach your final destination, just because that's the Hypermedia way, seems
very annoying.

Secondly, what does it mean that the API should be easy to evolve. Ignoring the
design problems regarding the technology chosen to implement the service, this
means that it is desirable that any change in the service's interface will have
no impact on existing clients. For example, adding a new data field, or changing
the structure of URLs should require no developer intervention in the clients.
Is this achievable? Hypermedia proponents argue that moving from entity IDs to
URLs and relationship tags will decouple the API client from changes in the
service. It's true for URLs, clients will no longer be required to know which ID
to append to which string to obtain the URL needed to update or delete a
particular resource. All they have to do right now is follow the links based on
the values of the relationship tags. Unfortunately, this seems to only move to
problem elsewhere. URL changes are now free of charge, but changing the name of
a relationship is now a breaking change. I have not seen a single presentation,
nor read a single article, in which this breaking change is mentioned. Everybody
talks as if Hypermedia APIs are the panacea for breaking changes in API design.
They **do** indeed suggest there's just a balance, but I've seen no one
mentioning that it will still be possible to break clients.

Here's what **I understand** they're saying. Having a predefined media type, e.g.
application/vnd.collection+json or application/hal+json, will reduce (or
even prevent) breaking changes, and as such allow greater flexibility in the
evolution of the API. For example, instead of having a predefined URL like...

    GET /categories/

...which would return a collection of JSON objects, each of which contains an
entity ID:

~~~json
[
  {
    "id": 1,
    "name": "category 01"
  },
  {
    "id": 2,
    "name": "category 02"
  }
]
~~~

...it's better to have the first resource return objects replacing IDs with URLs
(using `application/hal+json` as the media type):

    GET /categories/

~~~json
[
  {
    "_links": {
      "self": { "href": "https://api.example.com/categories/1/" }
    },
    "name": "category 01"
  },
  {
    "_links": {
      "self": { "href": "https://api.example.com/categories/2/" }
    },
    "name": "category 02"
  }
]
~~~

Now, instead of having to read the docs to see that you're required to append
the value of the `id` property to the URL `https://api.example.com/categories/`
in order to obtain a valid URL for a single category, you just have to follow
the link. You can for example send a DELETE request to one of the two `href`
properties in order to remove that category.

Indeed, the API service has now more flexibility in changing the structure of
individual category URLs. However, renaming the `_links` and `self` properties
will result in a breaking change. I admit, though, that the probability to
perform this change is **probably** less than changing the URL.

Another strategy to change the URL structure in the first case (when the API
client has the responsibility of building the resource URL), while maitaining
compatibility, is to use a redirect. But this will only work for HEAD and GET
requests. The spec [disallows][3] [automatic][4] [redirection][5] in user agents
for other methods (like PUT, POST, and DELETE), unless it can be confirmed by the
user. This is not a requirement of the spec that I see supported in apps.
Requiring user input on such a technical aspect isn't really user friendly.

As a side note, you can't be sure that clients won't depend on the format of the
URLs though, all you can do is warn them not to. If your service becomes successful
and too many clients have come to rely on the URL structure, then I bet no one
will be willing to break the existing clients just because there was a warning
in the API docs. A better strategy might be to randomize the structure of the
URLs from the start, and thus minimize the risk of having clients rely on the
structure.

In the first scenario there are three moving parts:

 - the name of the ID property (I've used `id` in the examples above)
 - the base URL used to construct the full URL
 - the algorithm to construct the full URL

These all represent opportunities to break API clients. Whenever you change one
of them, the API clients will break.

The moving parts for the second scenario depend on the format you choose to
store the URLs. If you're using HAL, then there are three moving parts:

 - the name of the `_links` property
 - the structure of the `_links` object
 - the name of the relationship (e.g., `self`)
 - the structure of individual relationship objects
 - the name of the `href` attribute

Changing any of the above will break API clients. But, again, as I said above,
it's probably less likely to perform any of these changes. Unless... you want
to migrate to Collection+JSON, or some other Hypermedia format, because the HAL
standard isn't standardizing all the things you need in your API. How likely
would that be? Probably you'll decide to extend the format, instead of changing
it.

In conlusion, dropping entity IDs in favour of full URLs and relationship tags
is beneficial to the API service by allowing future changes in the URL structure,
while not posing implementation problems to API clients (it's probably easier to
just follow a fully formed URL than to concatenate some strings, and just then
follow the resulted URL).

Forms in Resources
------------------
Let's see another type of change that Hypermedia proponents present as beneficial.
Most of the APIs advertised as REST nowadays leave the details of resource
creation and updates for the documentation. Following the same line of thought,
the Hypermedia style says we should add a new type of metadata to the representation
of resources that support create and update operations. That metadata is very
similar to an HTML form:

~~~html
<form action="https://api.example.com/categories" method="post">
  <input name="category-name" type="text">
  <input type="submit">
</form>
~~~

The above form could be used in an HTML page to allow users to create new
categories. Current Hypermedia proposals look like this (using
Collection+JSON as a format):

    GET /categories
    Accept: application/vnd.collection+json

~~~json
{
  "collection": {
    "version": "1.0",
    "href": "https://api.example.com/categories/",
    "links": [],
    "items": [
      {
        "href": "https://api.example.com/categories/1/",
        "data": [
          {
            "name": "name",
            "value": "category 01",
            "prompt": "Category Name"
          }
        ],
        "links": []
      },
      {
        "href": "https://api.example.com/categories/2/",
        "data": [
          {
            "name": "name",
            "value": "category 02",
            "prompt": "Category Name"
          }
        ],
        "links": []
      },
    ],
    "template": {
      "data": [
        {
          "name": "category-name",
          "value": "",
          "prompt": "Category Name"
        }
      ]
    }
  }
}
~~~

Ignoring the verbosity required to represent this, the object under the `template`
property is akin to the HTML form you've seen above. It defines a template of
name-value pairs where the value may be predefined or not, in which case the API
client has to supply it. The `prompt` property is similar to the HTML `label`
element.

In the current incarnation of the Shoeboxed API, the developer will have to read
the docs to find out what is the structure of the JSON request body allowed to
be sent via POST or PUT. That is not necessary here, however, most of the time
it's necessary to know the value of the keys in order to match them with the
data you want to send. UI can be automatically derived from the above template,
but if the API client does not want to depend on the key values, she/he will not
be able to style them differently, or position them differently in the layout
created by the designer. It is, indeed, helpful for deriving scaffolds, but
that's all in my opinion. People will want customized UI, or maybe there won't
be any UI at all. Then, the client has a dependency on those keys, and this is
an area which can result in breaking changes if modified.

Also, in Collection+JSON there's no metadata on what are some valid values for
those fields. They can be anything, in which case API services will have to
rely on documentation to provide more information, e.g. some field represents
a date, or to extend the format. Ideally, in a non-breaking way, so that interoperability
with existing Collection+JSON clients is not affected.

Then again, HTML is semantically richer than this `template` thing. In HTML5
there are a plethora of field types: text, password, radio, checkbox, email,
number, phone, color, etc. All these metadata allows the browser to render each
of these components in a predefined way. But developers will want to change them
via CSS, and then there's a dependency link between the type of input field, or
a given attribute value, like `id` or `class`. If you're messing up with that
the CSS will break. That's the kind of dependency we're talking about in APIs
too. API clients will start depending on some of the structure in that
`template` object. The API service will have to pay attention to future changes
then. How is this normally solved? Using versioning of course. You can't get rid
of versioning even with Hypermedia APIs. However, now, instead of having the
client depend on a single version, your custom representation of the resources,
you're forcing it to depend on two versions: first, the media type version, and
secondly, the version of the data you're embedding in the
`collection.items.data` objects.

Anyway, there is value in having additional meta data. What I'm saying is that
it won't save you from breaking changes. All this is doing is separating two
layers of the API that will most likely evolve at different paces: the
representation of the metadata, and the representation of the data.

One form field that I see value in adding is a `one-of` and `many-of` type. It
would have the same semantics as the `radio` and `checkbox` field types, or as a
`select` element (with the optional `multiple` attribute). The set of values
permitted for that field would be readily available to clients, without having
to read in the docs what's the JSON array of strings of such values, or which
URL to GET to obtain them. Again, this won't save the API service from breaking
changes (or even validation), but will automate the process of populating such
UI elements. In the example representation below there are only three allowed
values for the `currency` field.

~~~json
{
  "template": {
    "data": [
      {
        "name": "currency",
        "type": "many-of",
        "allowed": [ "EUR", "RON", "USD" ],
        "value": null,
        "prompt": "Currency"
      }
    ]
  }
}
~~~

Or, even by specifying a URL as a data source.

~~~json
{
  "template": {
    "data": [
      {
        "name": "currency",
        "type": "many-of",
        "allowed": "https://api.example.com/currencies#items",
        "value": null,
        "prompt": "Currency"
      }
    ]
  }
}
~~~

The fragment part can be used to navigate inside the response to a specific
property:

    GET https://api.example.com/currencies#items

~~~json
{
  "items": [ "EUR", "RON", "USD" ]
}
~~~

This eases some of the work of obtaining the allowed values, but the name of the
field, "currency", is still subject to breaking changes. You're actually forced
to keep it unless you increment the API version, because you have no idea how
people depend on it.

Another issue that might appear is with completely automated clients, which might
want to choose one of the values in the list based on their name, index, or maybe
some ID (similar to the HTML `id` attribute). Even if the client is willing to
follow the Hypermedia style of communications, there's a point at which it has
no other choice than to rely on a concrete value. Taking Shoeboxed as an example,
if someone wants to automate the task of completing the currency field, he might
decide to hardcode one of the values in the list of currencies, say EUR. This is
a general problem with API forms that allow a restricted set of values. There
will be at least one client that will need to create a dependency on one of the
values. Simply because his usage of the API does not (want to) rely on human
intervention. Hypermedia APIs are all nice and dandy when you can push the final
responsibility on the user of the application, but that's not always possible.

Representing Flows Using Links
------------------------------
Hypermedia APIs are also advocated for their advantages when representing flows,
or state machines. The set of subsequent states would be represented as a set of
URLs. The developer would then be saved from reading any docs regarding the flow
and just instruct his API client to follow the links based on `rel` attributes
or properties. I have never had to represent a state machine in an API, or
that's what I think at least, but I don't see how this style of representation
might improve anything except automated derived UIs, in which the final
responsibility of choosing one of the available next states is on the human
being. If the communication between the service and the client is fully
automated, I bet someone will create a dependency on one of the rel values. Why?
To verify its presence, and follow the link when it's there, or not when it
isn't. Agreed, let's just not forget that we've still created a bond between the
service and the client. Also, how do you communicate to the client the reason
for that relationship not being there? The developer might want to log the fact
that the rel is not there and a possible reason. I haven't yet seen any
proposals to this issue.

Root Resources
--------------
Another part of the Hypermedia trend is to have all a single entry point to
your service. The client should `GET https://api.example.org/` and from there
follow its path to the resources it's interested it. Performance issues aside,
I don't see any value in this when the next-level resource isn't logically
subordinate to the root resource. It's almost the same thing as the above
discussion about entity IDs versus entity URLs in representations. I see value
in having links between entities, but I don't see why would someone want to
traverse a graph of links from the root URL to some other resources which
presents no connection between them. I think that a corollary of the
<abbr title="Hypermedia As The Engine Of Application State">HATEOAS</abbr> rule
is that if you don't have any state to pass, then don't use a link.

Take for example the [GitHub API's root resource](https://api.github.com/):

~~~json
{
  "current_user_url": "https://api.github.com/user",
  "authorizations_url": "https://api.github.com/authorizations",
  "emails_url": "https://api.github.com/user/emails",
  "emojis_url": "https://api.github.com/emojis",
  "events_url": "https://api.github.com/events",
  "following_url": "https://api.github.com/user/following{/target}",
  "gists_url": "https://api.github.com/gists{/gist_id}",
  "hub_url": "https://api.github.com/hub",
  "issue_search_url": "https://api.github.com/legacy/issues/search/{owner}/{repo}/{state}/{keyword}",
  "issues_url": "https://api.github.com/issues",
  "keys_url": "https://api.github.com/user/keys",
  "notifications_url": "https://api.github.com/notifications",
  "organization_repositories_url": "https://api.github.com/orgs/{org}/repos/{?type,page,per_page,sort}",
  "organization_url": "https://api.github.com/orgs/{org}",
  "public_gists_url": "https://api.github.com/gists/public",
  "rate_limit_url": "https://api.github.com/rate_limit",
  "repository_url": "https://api.github.com/repos/{owner}/{repo}",
  "repository_search_url": "https://api.github.com/legacy/repos/search/{keyword}{?language,start_page}",
  "current_user_repositories_url": "https://api.github.com/user/repos{?type,page,per_page,sort}",
  "starred_url": "https://api.github.com/user/starred{/owner}{/repo}",
  "starred_gists_url": "https://api.github.com/gists/starred",
  "team_url": "https://api.github.com/teams",
  "user_url": "https://api.github.com/users/{user}",
  "user_organizations_url": "https://api.github.com/user/orgs",
  "user_repositories_url": "https://api.github.com/users/{user}/repos{?type,page,per_page,sort}",
  "user_search_url": "https://api.github.com/legacy/user/search/{keyword}"
}
~~~

To me, this response looks like a collection of other services because there's
simply no relationship between this root resource and the ones listed. Yes,
they're related conceptually around what GitHub does, but other than that I see
no reason not to depend on the URL directly. Why wouldn't I depend directly on
the URL for starred gists? It seems like a service in its own right. What's the
difference between relying on the property name vs. relying directly on the URL
in this case? Maybe because the chances of changing the URL schemes are greater
than the chances of renaming the relationship tags? Maybe.

We seem to anthropomorphize API clients too much with all this link following.
But then again, do we always navigate to the root of the websites we visit? No.
People are allowed to have bookmarks. Why shouldn't we allow this to API clients
as well?

Also, another observation, if the service is forcing clients to navigate through
mare than one layer of links, without any logical connection between them, then
they'll introduce more space for future breaking changes. Each relationship tag
the client has to hardcode to know where to go is a point in the contact surface
between the service and the client. If the client would have to follow more than
one link to get to the starred gists list, then it is certainly better to let
the client depend on the URL directly. One contact surface point (the URL
structure) versus at least two points when relying on rel propeties.

In conclusion, I see value in linking from some root resource to entities, but
not in linking from some root resource to resources that what are normally
called collection resources, i.e., the URLs used to retrieve a list of entities,
or create new ones. I prefer to see those as web services in their own right. If
we choose the root resource style, we might as well create a single root
resource for all the APIs available today. A web directory for APIs.

Law of Demeter in APIs
----------------------
Steve Klabnik tries to make a parallel between the famous Law of Demeter, that
you've probably learned of by reading about Object-Oriented design, to how APIs
are designed in [this presentation][6]. Honestly, I didn't get the parallel, it
seemed he didn't took it to its logical conclusion, but the parallel has potential.

In the root resource case, you might be required to traverse multiple levels
of resources, each resource representation lends itself to breaking changes.
The more links you have to follow, the greater the risk of breaking changes.

This is the Law of Demeter for web APIs. Reduce the number of links a client
has to follow. Replace the dots in OO languages with GET requests in a web API
and it's (almost) the same thing.

Conclusion
----------
That's **my current view** of Hypermedia APIs, and I guess I'm leaning towards
it, or at least most of it. However, adopting this style might gain you some
flexibility, but not as much as some people make it appear. Spend some time and
try to put on a piece of paper how many contact points there might be between
your API service and some hypothetical API client. For each property name
retrieved via a GET request you have one contact point. For each form field in a
resource that allows creation or updates, you have one contact point. For each
URL that's not "hidden" behind a relationship tag you have another contact point.
There are probably others I haven't yet discovered.

I think the Hypermedia style provides value, but as any hyped thing in our
industry, it creates a lot of cargo cult programming, where things are being
done just because they're "best practices". And the only placed they've been
practiced was on some blog posts.


Resources
---------
- Books
    - [RESTful Web Services Cookbook](http://www.amazon.com/RESTful-Web-Services-Cookbook-Scalability/dp/0596801688)
- Videos
    - [Designing Hypermedia APIs](https://www.youtube.com/watch?v=LvtUsJKfeXg)
    - [Hypermedia APIs](https://www.youtube.com/watch?v=tfRhs0KIVs8)
    - [RPC to REST](https://www.youtube.com/watch?v=Nh6VeuvVRdQ)
    - [Web scraping: Reliably and efficiently pull data from pages that don't expect it](https://www.youtube.com/watch?v=52wxGESwQSA)
- Articles
    - [Nobody Understands REST or HTTP](http://blog.steveklabnik.com/posts/2011-07-03-nobody-understands-rest-or-http)
    - [Some People Understand REST and HTTP](http://blog.steveklabnik.com/posts/2011-08-07-some-people-understand-rest-and-http)
    - [A Hypermedia API Reading List](http://blog.steveklabnik.com/posts/2012-02-27-hypermedia-api-reading-list)
    - [How much REST should your web API get?](http://blog.restlet.com/2013/05/02/how-much-rest-should-your-web-api-get/)
- Proposed Standards
    - [Collection+JSON][7]
    - [HAL][8]
    - [Siren][9]
    - [JSON API][10]


[0]: https://shoeboxed.com
[1]: http://developer.shoeboxed.com/overview
[2]: http://developer.github.com/
[3]: http://pretty-rfc.herokuapp.com/RFC2616#status.301
[4]: http://pretty-rfc.herokuapp.com/RFC2616#status.302
[5]: http://pretty-rfc.herokuapp.com/RFC2616#status.307
[6]: https://www.youtube.com/watch?v=LvtUsJKfeXg#t=7m12s
[7]: http://amundsen.com/media-types/collection/
[8]: http://stateless.co/hal_specification.html
[9]: https://github.com/kevinswiber/siren
[10]: http://jsonapi.org/
