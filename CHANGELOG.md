## 0.0.1

- Initial version.

## 0.0.2

- Readme updated.

## 0.0.3

- http updated to `1.4.0`.
- Readme updated.

## 0.0.3+1

- Readme updated.

## 0.0.3+2

- Topics added in description.

## 0.0.4

- Download and Upload progress callback added

## 0.0.4+1

- Readme updated to highlight the `call` method & Customizability `NetworkRequest` of explained

## 0.1.0

### New Features
- Successful responses status codes made customizable. Defaults to 200-299. 
- More information given to decodeError.

### Breaking Change
- Typo fixed: `unautherizedStatusCode` has been updated to `unauthorizedStatusCode`. You will need to rename it if you have overridden it in your extended `NetworkRequest`; otherwise, you can ignore this.

- `headers` field in `NetworkRequest` made private to avoid any unintended behaviour. It is no longer accessible for subclasses.

- `decodeError` parameters have chaged to send Reponse instead of dynamic.