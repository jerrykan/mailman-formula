{%- from "mailman/map.jinja" import mailman with context -%}

include:
  - mailman

{%- for domain, lists in salt['pillar.get']('mailman:lists', {})|dictsort %}
{%-   for name, cfg in lists|dictsort %}
{%-     if cfg.get('absent', False) %}

mailman-rmlist-{{ name }}:
  cmd.run:
    - name: {{ mailman.rmlist_bin }} {{ name }}
    - onlyif: test -f {{ mailman.lists_dir }}/{{ name }}/config.pck
    - require:
      - pkg: mailman-package

{%-     else %}

{%- set urlhost = cfg.get('urlhost', domain) %}
{%- set emailhost = cfg.get('emailhost', domain) %}
{%- set password = cfg.get('password', salt['grains.get_or_set_hash']('mailman:admin_password_' ~ name)) %}

mailman-newlist-{{ name }}:
  cmd.run:
    - name: {{ mailman.newlist_bin }} -q -u {{ urlhost }} -e {{ emailhost }} {{ name }} {{ cfg.admin }} '{{ password }}'
    - unless: test -f {{ mailman.lists_dir }}/{{ name }}/config.pck
    - require:
      - pkg: mailman-package

{%-     endif %}
{%-   endfor %}
{%- endfor %}
