---
layout: default
---

<section class="posts">
  <h2>Posts</h2>
  <ol>
    {% for post in site.posts %}
      <li>
        <time title="{{ post.date }}" pubdate="{{ post.date }}">{{ post.date | date: "%b %d, %Y" }}</time>
        <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
      </li>
    {% endfor %}
  </ol>
  <div class="related">Go to <a href="/">homepage</a> or subscribe to the <a href="#" class="feed">RSS feed</a></div>
</section>
