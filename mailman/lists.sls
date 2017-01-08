{%- from "mailman/map.jinja" import mailman with context -%}

{%- set domains = salt['pillar.get']('mailman:lists', {}) %}

include:
  - mailman

{% if domains -%}
mailman-lists-confdir:
  file.directory:
    - name: {{ mailman.lists_conf_dir }}
    - require:
      - pkg: mailman-package
{% endif %}

{%- for domain, lists in domains|dictsort %}
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
{% set conf_file = mailman.lists_conf_dir ~ '/' ~ name ~ '_conf.py' -%}

mailman-newlist-{{ name }}:
  cmd.run:
    - name: {{ mailman.newlist_bin }} -q -u {{ urlhost }} -e {{ emailhost }} {{ name }} {{ cfg.admin }} '{{ password }}'
    - unless: test -f {{ mailman.lists_dir }}/{{ name }}/config.pck
    - require:
      - pkg: mailman-package

mailman-config_file-{{ name }}:
  file.managed:
    - name: {{ conf_file }}
    - source: salt://mailman/files/list_config.py.jinja
    - template: jinja
    - context:
        name: {{ name }}
        admin: {{ cfg.admin }}
        emailhost: {{ emailhost }}
        urlhost: {{ urlhost }}
        config: {{ cfg.get('config', {})|json }}

mailman-list_config-{{ name }}:
  cmd.run:
    - name: {{ mailman.config_list_bin }} -i {{ conf_file }} {{ name }}
    - onlyif: test -f {{ mailman.lists_dir }}/{{ name }}/config.pck
    - onchanges:
      - cmd: mailman-newlist-{{ name }}
      - file: mailman-config_file-{{ name }}

{%-     endif %}
{%-   endfor %}
{%- endfor %}
