# frozen_string_literal: true

all
rule 'MD029', style: :ordered
exclude_rule 'MD013' # Line length
exclude_rule 'MD033' # Inline HTML
exclude_rule 'MD005' # List item indentation - bug https://github.com/markdownlint/markdownlint/issues/374
exclude_rule 'MD007' # List item indentation - bug https://github.com/markdownlint/markdownlint/issues/313
