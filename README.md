# pass-audit - an extension for the [`pass` password store](https://www.passwordstore.org/)

`pass-audit` helps you check your passwords against known vulnerable ones
included in the [Have I Been Pwned (HIBP) list of exposed
passwords](https://haveibeenpwned.com/Passwords).

## Installation

```
git clone https://github.com/benburwell/pass-audit.git
cd pass-audit
sudo make install
```

**Note:** On macOS, you will need to use `sudo make install PREFIX=/usr/local`
instead of `sudo make install`.

## Usage

Check all your passwords against the HIBP database:

```
pass audit all --hibp
```

For more examples, see `man pass-audit`.

