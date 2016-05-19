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
    <li><a href="https://stackoverflow.com/users/58808/ionut-g-stan">StackOverflow</a></li>
  </ul>
</section>

<section class="talks">
  <h2>Talks &amp; Presentations</h2>
  <ol>
    <li>
      <p>
        <a href="http://itakeunconf.com/sessions/lets-write-a-parser">I T.A.K.E. Unconference 2016</a>,
        <a href="http://static.igstan.ro/lets-write-a-parser.pdf">Let's Write a Parser</a>
      </p>
      <script async class="speakerdeck-embed" data-id="230b8676fc7b46cba354f95edd7fee01" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
    <li>
      <p>
        <a href="http://2015.itakeunconf.com/sessions/ionut-stan-lets-write-a-type-checker">I T.A.K.E. Unconference 2015</a>,
        <a href="http://static.igstan.ro/lets-write-a-type-checker.pdf">Let's Write a Type Checker</a>
      </p>
      <script async class="speakerdeck-embed" data-id="c6e99e6a45214679a4e651000720e497" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
  </ol>
  <div class="related">List <a href="{{ 'talks.html' | prepend: site.baseurl }}">all presentations</a></div>
</section>
