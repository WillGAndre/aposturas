# aposturas
Sharing script used for a tentatively "secure" approach for file management and password/script sharing.
The main approach is to run: `./gitshare.sh -e` before each `git push` and `./gitshare.sh -d` after each `git clone/pull` in your repo.
<pre>
.
├── archive                 Archives saved in .git
├── current                 File input directory (ignored by .git)
└── gitshare.sh
</pre>
<pre>
./gitshare.sh [-u [-e]] | -up | -e | -d
    -u: Upload this script. Optionally use -e to encrypt before upload.
    -up: Upload Password
    -e: Encrypt the 'current' directory and move to 'archive'.
    -d: Decrypt the latest archive in 'archive'.
</pre>
<pre>Specs:
    - aes-256-cbc
    - pbkdf2
</pre>
<pre>Future Work:
    - git hooks
</pre>