# AT&T M2X mRuby Client

[AT&T M2X](http://m2x.att.com) is a cloud-based fully managed time-series data storage service for network connected machine-to-machine (M2M) devices and the Internet of Things (IoT).

The [AT&T M2X API](https://m2x.att.com/developer/documentation/overview) provides all the needed operations and methods to connect your devices to AT&T's M2X service. This client provides an easy to use interface for the lightweight Ruby interpreter for devices, [mRuby](http://www.mruby.org).

Refer to the [Glossary of Terms](https://m2x.att.com/developer/documentation/glossary) to understand the nomenclature used throughout this documentation.

# Getting Started

1. Signup for an [M2X Account](https://m2x.att.com/signup).
2. Obtain your _Master Key_ from the Master Keys tab of your [Account Settings](https://m2x.att.com/account) screen.
2. Create your first [Device](https://m2x.att.com/devices) and copy its _Device ID_.
3. Review the [M2X API Documentation](https://m2x.att.com/developer/documentation/overview).

## Usage

In order to communicate with the M2X API, you need an instance of [M2X::Client](mrblib/m2x-client.rb). You need to pass your API key in the constructor to access your data.

```ruby
m2x = M2X::Client.new("<YOUR-API-KEY>")
```

The client object can be used to obtain object handles for M2X devices, streams and distributions.

- [Device](mrblib/m2x-client-device.rb)
  ```ruby
  device = m2x.device("<DEVICE-ID>")
  ```

- [Stream](mrblib/m2x-client-device.rb)
  ```ruby
  stream = m2x.stream("<STREAM-NAME>")
  ```

- [Distribution](mrblib/m2x-client-distribution.rb)
  ```ruby
  distribution = m2x.distribution("<DISTRIBUTION-ID>")
  ```

To keep the library size small, a minimal subset of the M2X API is provided in the object wrappers. However, the object client can be used to directly access any M2X API endpoint using REST methods:
```ruby
  m2x = M2X::Client.new("<YOUR-API-KEY>")
  m2x.get("/some_path")
  m2x.post("/some_other_path", nil, {foo:'bar'}, {"Content-Type" => "application/json"})
```

Refer to the documentation on each class for further usage instructions.

## Versioning

This gem aims to adhere to [Semantic Versioning 2.0.0](http://semver.org/). As a summary, given a version number `MAJOR.MINOR.PATCH`:

1. `MAJOR` will increment when backwards-incompatible changes are introduced to the client.
2. `MINOR` will increment when backwards-compatible functionality is added.
3. `PATCH` will increment with backwards-compatible bug fixes.

Additional labels for pre-release and build metadata are available as extensions to the `MAJOR.MINOR.PATCH` format.

**Note**: the client version does not necessarily reflect the version used in the AT&T M2X API.

## License

This gem is provided under the MIT license. See [LICENSE](LICENSE) for applicable terms.
