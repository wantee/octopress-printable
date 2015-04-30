---
---
{% capture url %} /blog/2015/04/29/foo {% endcapture %}
{{ url | url2filename }}

{% capture url %} /2015/04/29/bar {% endcapture %}
{{ url | url2filename }}

{% for post in site.posts %}
  <li> <a href={{ post.url }}> {{ post.url }} </a> </li>
{% endfor %}
