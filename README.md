# fluent-plugin-script

Fluent filter plugin to external ruby script

[![Build Status](https://travis-ci.org/SNakano/fluent-plugin-script.svg)](https://travis-ci.org/SNakano/fluent-plugin-script)

## install

``
gem install fluent-plugin-filter-script
``

## Configuration Example

#### fluent.conf
```
<filter foo.bar.*>
  type script
  path /etc/fluentd/example.rb
</filter>
```

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
