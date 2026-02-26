# Expression Evaluator Reference

Technical reference for the kosmos expression evaluator — the engine that resolves `{{ }}` templates, `$var` interpolation, pipe filters, comparisons, and function calls.

**Source:** `crates/kosmos/src/interpreter/expr.rs`

---

## Template Syntax

### Interpolation Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `{{ expr }}` | Handlebars-style phasis | `{{ $name }}` |
| `{{ bareword }}` | Auto-variable (becomes `$bareword`) | `{{ content }}` → `{{ $content }}` |
| `{{ var \| func }}` | Pipe filter | `{{ items \| length }}` |
| `$var` | Inline variable | `prefix/$var/suffix` |
| `func($arg)` | Top-level function call | `json_encode($data)` |

### Evaluation Order

`eval_string(template, scope)` processes templates in this order:

1. **Early return** for simple `$var` references (no `{{}}`, no `/`, no file extensions)
2. **Top-level function call** detection (e.g., `yaml_encode($var)` without braces)
3. **Character-by-character** parsing of `{{ ... }}` and `$var` patterns

Inside `{{ }}`, bare identifiers are auto-prefixed with `$`: `{{ content }}` becomes `{{ $content }}`.

### Output Conversion

| Type | Output |
|------|--------|
| String | As-is |
| Number | String representation |
| Bool | `"true"` or `"false"` |
| Null | Empty string `""` |
| Array/Object | JSON serialization |

---

## Variable References

### Simple Variables

`$var` looks up `var` in the current scope. Returns `Null` if not found.

### Dot Notation

`$var.field.subfield` traverses nested objects. Supports array indexing: `$var.items[0].name`.

### File Extension Detection

The evaluator distinguishes file extensions from property access. `$var.md` is treated as a file path (not `$var` property `md`). Known extensions: `.md`, `.yaml`, `.json`, `.html`, `.css`, `.js`, `.ts`, `.tsx`, `.rs`, etc.

---

## Pipe Filters

```
{{ var | func }}
```

Pipes pass the left-hand value to a function. Internally:

1. `{{ items | length }}` normalizes to `length($items)`
2. The left value is bound as `$_` in a synthetic scope
3. If the right side has no parens, it becomes `func($_)`

### Chaining

Pipe filters cannot be chained in `{{ }}` syntax. Use function composition instead:

```yaml
# Not supported: {{ data | json_encode | length }}
# Use: length(json_encode($data))
```

---

## Operators

### Comparison Operators

| Operator | Example | Notes |
|----------|---------|-------|
| `==` | `$x == 5` | Equality (type-coercing for numbers) |
| `!=` | `$x != 5` | Inequality |
| `>` | `$x > 5` | Greater than |
| `<` | `$x < 5` | Less than |
| `>=` | `$x >= 5` | Greater or equal |
| `<=` | `$x <= 5` | Less or equal |
| `in` | `$val in $arr` | Membership (array, string, object) |

**`in` operator** works on three types:
- **Array:** `$value in [1, 2, 3]` — element membership
- **String:** `$needle in $haystack` — substring check
- **Object:** `$key in $object` — key existence

### Logical Operators

| Operator | Precedence | Short-circuits |
|----------|------------|----------------|
| `\|\|` (OR) | Lower | On `true` |
| `&&` (AND) | Higher | On `false` |
| `!` / `not` | Highest | N/A |

### Arithmetic Operators

| Operator | Behavior |
|----------|----------|
| `+` | Addition (numbers), concatenation (strings, arrays) |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division (error on divide-by-zero) |

`Null` coerces to `0.0` for arithmetic. `[a, b] + [c, d]` produces `[a, b, c, d]`. `"hello" + " world"` produces `"hello world"`.

---

## Expression Precedence

Evaluated in this order (highest to lowest):

1. Logical negation: `!expr`, `not expr`
2. Function calls: `func($arg)`
3. Pipe operator: `$left | func`
4. Logical operators: `&&`, `||`
5. Comparison operators: `==`, `!=`, `>`, `<`, `>=`, `<=`, `in`
6. Arithmetic operators: `+`, `-`, `*`, `/`
7. Dot notation: `$var.field.subfield`
8. Variable reference: `$var`
9. Literals: `'string'`, `[array]`, `{object}`, numbers, JSON

---

## Truthiness

| Type | Falsy | Truthy |
|------|-------|--------|
| Null | Always | Never |
| Bool | `false` | `true` |
| Number | `0`, `-0` | Any non-zero |
| String | `""` (empty) | Non-empty |
| Array | `[]` (empty) | 1+ elements |
| Object | `{}` (empty) | 1+ keys |

Used by `when:` conditions in render-specs and typos slots.

---

## Built-In Functions

### Time

| Function | Signature | Returns |
|----------|-----------|---------|
| `now()` | No args | Number (ms since epoch) |
| `timestamp_add_days(ts, days)` | (number, number) | Number |
| `timestamp_add_hours(ts, hours)` | (number, number) | Number |
| `timestamp_add_minutes(ts, mins)` | (number, number) | Number |
| `timestamp_before(t1, t2)` | (number, number) | Boolean |

### Generators (Impure)

| Function | Signature | Returns |
|----------|-----------|---------|
| `uuid()` | No args | String (UUID v4) |
| `random_hex(bytes?)` | (optional number, default 32) | String (hex, cryptographically secure) |

### Encoding

| Function | Signature | Returns |
|----------|-----------|---------|
| `json_encode(value)` | (any) | String (JSON) |
| `json_decode(string)` | (string) | Parsed value |
| `yaml_encode(value)` | (any) | String (YAML) |
| `yaml_entity_list(entities)` | (array of {id, data}) | String (YAML entity format) |
| `base64url_encode(value)` | (any) | String (base64url, no padding) |
| `base64url_decode(string)` | (string) | Value (auto-parses JSON if possible) |

### Collections

| Function | Signature | Returns |
|----------|-----------|---------|
| `length(value)` | (array\|string\|object) | Number |
| `len(value)` | Alias for `length()` | Number |
| `keys(object)` | (object) | Array of strings |
| `values(object)` | (object) | Array of values |
| `entries(object)` | (object) | Array of {key, value} |
| `join(array, sep?)` | (array, optional string) | String (default separator: `\n`) |

### Strings

| Function | Signature | Returns | Example |
|----------|-----------|---------|---------|
| `suffix(string)` | (string) | After last `/` | `suffix("eidos/theoria")` → `"theoria"` |
| `prefix(string)` | (string) | Before last `/` | `prefix("eidos/theoria")` → `"eidos"` |

### Hash

| Function | Signature | Returns |
|----------|-----------|---------|
| `blake3(value)` | (any) | String (hex hash of JSON-serialized value) |

---

## Literals

### Strings

Single-quoted strings with escape sequences:

```
'hello world'
'it\'s escaped'
```

### Arrays

```
[$var, $foo.bar, "literal", 42]
```

Elements are evaluated as phaseis. Comma-separated, respects nesting.

### Objects

```
{eidos: $eidos_name, errors: $validation.errors}
```

Keys can be quoted or unquoted. Values are phaseis.

---

## Error Handling

### Silent Failures

| Situation | Behavior |
|-----------|----------|
| Unknown function name | Returns `None` → treated as string literal |
| Missing variable | Returns `Null` → coerces in operations |
| Unknown pipe filter | Returns `Null` silently |

### Explicit Errors

| Situation | Error |
|-----------|-------|
| Unclosed `{{ }}` | `"Unclosed {{ in string"` |
| Division by zero | `"Division by zero"` |
| `json_decode()` on non-string | Type error |
| `keys()` on non-object | Type error |
| `length()` on incompatible type | Type error |
| Arithmetic on non-numbers | Type error (except `Null` → `0.0`) |

---

## Usage Contexts

The expression evaluator is used in:

| Context | How It's Used |
|---------|---------------|
| **Typos templates** | `{{ slot \| filter }}` in template strings |
| **Render-spec bindings** | `{field}` resolved against entity data |
| **`when:` conditions** | Boolea phasiss for conditional rendering/slot gating |
| **Praxis steps** | `$var` interpolation in step parameters |
| **Reflex actions** | `$entity`, `$previous`, `$bond` scope variables |

### Scope Variables by Context

| Context | Available Variables |
|---------|-------------------|
| Praxis execution | `$param_name` (from praxis params), `$step_result` (from bind_to) |
| Reflex execution | `$entity`, `$previous`, `$bond`, `$from`, `$to`, `$desmos` |
| Template rendering | Slot values as `$slot_name` |
| Render-spec binding | Entity data fields as `$field_name` |

---

## Validation

Three validation functions check expressions at bootstrap time:

- **`validate_expression_functions(expr)`** — checks against `KNOWN_FUNCTIONS`
- **`validate_expression_functions_with(expr, additional)`** — checks against extended list
- **`validate_expression_functions_dynamic(expr, known_list)`** — checks against provided list

Unknown functions are flagged during praxis validation at bootstrap, catching typos before runtime.

---

## Related

- [Typos Composition](typos-composition.md) — Template syntax in artifact definitions
- [Composition Guide](composition.md) — Fill patterns and slot filling
- [Two-Phase Bindings](../../explanation/architecture/two-phase-bindings.md) — `{field}` vs `$form.*` resolution timing
- [Reactive System Reference](../reactivity/reactive-system-reference.md) — Reflex scope variables
