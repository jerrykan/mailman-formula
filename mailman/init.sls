{%- from "mailman/map.jinja" import mailman with context -%}

mailman-package:
  pkg.installed:
    - name: {{ mailman.package }}
