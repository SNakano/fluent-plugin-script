# fluent-plugin-script

Fluent filter plugin to external ruby script.

[![Build Status](https://travis-ci.org/SNakano/fluent-plugin-script.svg)](https://travis-ci.org/SNakano/fluent-plugin-script)
[![Gem](https://img.shields.io/gem/dt/fluent-plugin-script.svg)](https://rubygems.org/gems/fluent-plugin-script)

## install

``
gem install fluent-plugin-script
``

### Requirements

| fluent-plugin-script | fluentd    |
|----------------------|------------|
| >= 0.1.0             | >= v0.14.0 |
| <  0.0.4             | <  v0.14.0 |

## Configuration

#### fluent.conf
```
<filter foo.bar.*>
  type script
  path /etc/fluentd/example.rb
</filter>
```

#### external ruby script

```
def start
  super
  # This is the first method to be called when it starts running
  # Use it to allocate resources, etc.
end

def shutdown
  super
  # This method is called when Fluentd is shutting down.
  # Use it to free up resources, etc.
end

def filter(tag, time, record)
  # This method implements the filtering logic for individual filters
  record
end

```

ref. http://docs.fluentd.org/articles/plugin-development#filter-plugins

#### Setting default directory

By setting the `FLUENT_PLUGIN_SCRIPT_DIR` environment variable, you can specify the default directory where scripts are located and access them without specifying the full path.

```bash
FLUENT_PLUGIN_SCRIPT_DIR="/etc/fluentd/"
```

```
<filter foo.bar.*>
  type script
  path example.rb
</filter>
```

## Example

#### example.rb

```ruby
def filter(tag, time, record)
  case tag
  when /.+\.code$/
    code(record)
  when /.+\.msg$/
    message(record)
  end
end

def code(record)
  if record.has_key?("key1")
    record["code"] = record["key1"].to_i
    record.delete("key1")
  end
  record
end

def message(record)
  case record["key2"].to_i
  when 100..200
    level = "INFO"
  when 201..300
    level = "WARN"
  else
    level = "ERROR"
  end
  record.delete("key2")

  record["message"] = level + ":" + record["key3"]
  record.delete("key3")
  record
end
```

#### Example 1
##### input
```
foo.bar.code: {"key1": "200"}
```

##### output
```
foo.bar.code: {"code":200}
```

#### Example 2
##### input
```
foo.bar.msg: {"key2":280,"key3":"Something happend."}
```

##### output
```
foo.bar.msg: {"message":"WARN:Something happend."}
```
