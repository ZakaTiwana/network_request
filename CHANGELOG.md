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
- `headers` field made private to avoid any unintended behaviour.

### Breaking Change
- Typo fixed: `unautherizedStatusCode` updated to `unauthorizedStatusCode`. You will have to rename if you have override it where you have extended `NetworkRequest` otherwise you can ignore. Rename to `unauthorizedStatusCode`  If you have override it else you can ignore.

- `headers` field made private to avoid any unintended behaviour. It is no longer accessible for subclasses.