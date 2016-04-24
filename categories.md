---
layout: default
---

<section class="posts">
  <h2>Categories</h2>
  <ol>
    {% for category in site.categories %}
      <li>
        <h2>{{ category | first }}</h2>
        {% for posts in category %}
          {% for post in posts %}
            {% if post.url %}
              <time title="{{ post.date }}" pubdate="{{ post.date }}">{{ post.date | date: "%b %d, %Y" }}</time>
              <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
            {% endif %}
          {% endfor %}
        {% endfor %}
      </li>
    {% endfor %}
  </ol>
  <div class="related">List <a href="#">all posts</a> or subscribe to the <a href="#" class="feed">RSS feed</a></div>
</section>
