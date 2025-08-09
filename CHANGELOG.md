## 0.2.0
- Made Decoding Error more explanatory with stack trace
- Added support for aborting requests. Introduced in http >= 1.5.0

## 0.1.1
- Made wasm compatible

## 0.1.0

### New Features
- Successful response status codes made customizable. Defaults to 200-299. 
- More information given to decodeError.
- Examples improved

### Breaking Change
- Typo correction: The property `unautherizedStatusCode` has been renamed to `unauthorizedStatusCode`.  
    - **Action required:** If you have overridden this property in your custom `NetworkRequest` subclasses, update your code to use the new name. If not, no changes are needed.

- `headers` field in `NetworkRequest` made private to avoid any unintended behaviour. It is no longer accessible for subclasses.

- `decodeError` parameters have changed to send CapturedResponse instead of dynamic.
    - **How to resolve:**  
        Previously, you may have implemented.  
         ```dart
        Exception? errorDecoder(dynamic data) {
            // ...your logic here
        }
        ```
        Now, update your method to:  
        ```dart
        Exception? errorDecoder(CapturedResponse response) {
            var data = response.body;
            // ...your logic here
        }
        ```
        This change gives you access to the full response object, so use `response.body` to access the data as before.

## 0.0.4+1

- Readme updated to highlight the `call` method & Customizability `NetworkRequest` of explained

## 0.0.4

- Download and Upload progress callback added

## 0.0.3+2

- Topics added in description.

## 0.0.3+1

- Readme updated.

## 0.0.3

- http updated to `1.4.0`.
- Readme updated.

## 0.0.2

- Readme updated.

## 0.0.1

- Initial version.