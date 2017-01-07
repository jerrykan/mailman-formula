{%- from "mailman/map.jinja" import mailman with context -%}

include:
  - mailman

mailman-conf:
  file.managed:
    - name: {{ mailman.conf_file }}
    - source: salt://mailman/files/mm_cfg.py.jinja
    - template: jinja
    - require:
      - pkg: mailman

