
Release tools for [adiary](https://github.com/nabe-abk/adiary).

----------------------------------------------------------------------
# [Japanese]

リリースツールとリリース用EXEファイルです。
実行時は、親ディレクトリから __tools/checker.pl という風に使用してください。

# checker.pl

リリース用チェッカーです。
文字コード、改行コード、デバッグコード（"debug"文字列のサーチ）を検出を実行します。

# release.sh

リリーサーです。adiary-3.00/ 等のディレクトリを自動的に生成し、
その中にリリース向けのファイルをコピーし、アーカイブ化します。

# pp.bat

Windows用adiary.exeを生成するためのバッチファイルです

# pp.opt

pp用実行オプション

# pp.ico

adiary.exe用iconファイル。署名エラーが起こるので現在は未使用。

