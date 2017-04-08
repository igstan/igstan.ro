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
        <a href="http://iasi.codecamp.ro/">Scalar 2017</a>,
        <a href="http://static.igstan.ro/modularity-a-la-ml.pdf">Modularity à la ML</a>
      </p>
      <script async class="speakerdeck-embed" data-id="467810402fbf4347a7d9c118963fa623" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
    <li>
      <p>
        <a href="http://iasi.codecamp.ro/">Codecamp Iași 2016</a>,
        <a href="http://static.igstan.ro/a-type-inferencer-for-ml-in-200-lines-of-scala.pdf">A Type Inferencer for ML in 200 Lines of Scala</a>
      </p>
      <script async class="speakerdeck-embed" data-id="f2df5b0458374a7b8d129e71b955fae4" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
    </li>
  </ol>
  <div class="related">List <a href="{{ 'talks.html' | prepend: site.baseurl }}">all presentations</a></div>
</section>
