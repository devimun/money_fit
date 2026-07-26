# Pretendard font asset

`PretendardVariable.ttf` is the unmodified variable TrueType font from the
[official Pretendard v1.3.9 release](https://github.com/orioncactus/pretendard/releases/download/v1.3.9/Pretendard-1.3.9.zip),
specifically `public/variable/PretendardVariable.ttf` in that archive. It is
kept because the existing Flutter font registration and theme use the
`Pretendard Variable` family; replacing it with a system font would change the
app's typography contract.

| Item | Value |
| --- | --- |
| Version | 1.3.9 |
| License | SIL Open Font License 1.1; full text: [LICENSE-Pretendard-1.3.9.txt](./LICENSE-Pretendard-1.3.9.txt) |
| TTF SHA-256 | `3090ccde0442bb347aa7685d9ba8b17436a60682df6e8f92a9a670de14056e22` |
| Release archive SHA-256 | `04be351a74d6bf7d60c480a3087e51d185485d35a52023142af1df19eb8c428a` |

To validate a replacement, run:

```sh
file assets/fonts/PretendardVariable.ttf
shasum -a 256 assets/fonts/PretendardVariable.ttf
```
