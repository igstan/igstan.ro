---
layout: default
---

<section class="posts">
  <h2>Posts</h2>
  <ol>
    {% for post in site.posts limit: 13 %}
      <li>
        <time title="{{ post.date }}" pubdate="{{ post.date }}">{{ post.date | date: "%b %d, %Y" }}</time>
        <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
      </li>
    {% endfor %}
  </ol>
  <div class="related">List <a href="{{ 'posts.html' | prepend: site.baseurl }}">all posts</a> or subscribe to the <a href="{{ 'feed.xml' | prepend: site.baseurl }}" class="feed">RSS feed</a></div>
</section>

<section class="online">
  <h2>Elsewhere</h2>
  <ul>
    <li><a href="https://github.com/igstan">GitHub</a></li>
    <li><a href="https://twitter.com/igstan">Twitter</a></li>
    <li><a href="https://stackoverflow.com/users/58808/ionut-g-stan">StackOverflow</a></li>
  </ul>
</section>

<section class="talks">
  <h2>Talks &amp; Presentations</h2>
  <ol>
    <li>
      <p>
        <a href="http://www.bjug.ro/editii/14.html">Bucharest Java User Group #14</a>,
        <a href="http://static.igstan.ro/scala-bjug-14.pdf">Scala — An Introduction</a>
      </p>
      <script async class="speakerdeck-embed" data-id="cf8eac90d815013013f95ec938f993c8" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
    <li>
      <p>
        <a href="http://wurbe.ro/2011/12/10/wurbe-48-colectia-de-iarna">Wurbe #48</a>,
        <a href="http://static.igstan.ro/pdf.js.pdf">pdf.js</a>
      </p>
      <script async class="speakerdeck-embed" data-id="4f8c037ab204f600220169f3" data-ratio="1.3333333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
    <li>
      <p>OpenAgile 2010, <a href="http://static.igstan.ro/functional-programming.pdf">Functional Programming</a></p>
      <script async class="speakerdeck-embed" data-id="4ec0f78c7cdd050054003cf5" data-ratio="1.3333333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
  </ol>
</section>
