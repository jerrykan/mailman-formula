{%- from "mailman/map.jinja" import mailman with context -%}

mailman-package:
  pkg.installed:
    - name: {{ mailman.package }}

mailman-service:
  service.running:
    - name: {{ mailman.service }}
    - enable: True
    - require:
      - pkg: mailman-package

mailman-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ mailman.service }}
