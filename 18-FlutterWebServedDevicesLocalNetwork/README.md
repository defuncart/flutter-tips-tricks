# 18 - Flutter Web Served to Devices in Local Network

When developing a Web App using Flutter, it can be very useful to test it on various devices (i.e. mobile, tablet) and operating systems before pushing it live.

## Built-in Web Server

Flutter’s built-in web server supports specifying the host and port:

```dart
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
```

`--web-hostname=0.0.0.0` allows connections from any IP on your local network, while `--web-port=8080` specifies the port.

Next, you need to determine your device's IP Address. This can be achieved via `ifconfig` on Linux/macOS, and `ipconfig` on Windows.

```sh
ipconfig getifaddr en0

192.168.0.1
```

Now, to open the Web App on another device connected to the same network, simply open `IP_ADDRESS:PORT`, i.e. `192.168.0.1:8080`.

## Local Server

When the Web App is connected to a local server (i.e. Node/Python/Java), you need to ensure that the server is bound to `0.0.0.0` and not `localhost`. This is because `localhost` only accepts connections running locally, whereas `0.0.0.0` is available to all devices on the network.

```js
app.listen(3000, '0.0.0.0')
```

Next, update the Web App to access the server from the computer's ip address instead of `localhost`. Dart defines (and launch configurations) are a simple way to easily swap between dev, localhost and local ip:

```dart
const baseUrl = String.fromEnvironment('API_URL');

flutter run --dart-define API_URL=192.168.0.1:3000
```

## CORS Warning

Running the Web App on the same port as the server can cause conflicts. However, when the Web App and server run on different ports (i.e. 8080 and 3000 respectively), Cross-Origin Resource Sharing (CORS) becomes an issue. In development mode, simply allow all origins.

## Profile/Release Builds

When testing performance, it is important to ensure that the app is in profile or release mode. Although `flutter run --release` is valid for testing on your local machine, `flutter run -d web-server --release` is not ideal as it spins up a basic, temporary sever not built for handling real user traffic.

Instead, build the web app using `flutter build web` and then server `/build/web` using a static file server:

```sh
flutter build web
cd /build/web
http-server -p 8080
```

This ensures that you can test the app under production conditions as what end users will be deployed.
