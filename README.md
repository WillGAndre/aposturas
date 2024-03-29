# aposturas
<pre>
.
├── archive                 Archives saved in .git
├── current                 File input directory (ignored by .git)
└── gitshare.sh
</pre>
Sharing script used for a tentatively "secure" approach for file management and password/script sharing.
The main approach is to run: `./gitshare.sh -e` before each `git push` and `./gitshare.sh -d` after each `git clone/pull` in your repo.
<pre>
./gitshare.sh [-u [-e]] | -up | -e | -d
    -u: Upload this script. Optionally use -e to encrypt before upload.
    -up: Upload Password
    -e: Encrypt the 'current' directory and move to 'archive'.
    -d: Decrypt the latest archive in 'archive'.
</pre>
The script can also be optionally used for password sharing/self-propagation via the following services ("random" selection by default):
<pre>
    - transfer.sh
    - 0x0.st
    - file.io
    - anonfiles
    - catbox
</pre>
----
<pre>Specs:
    - aes-256-cbc
    - pbkdf2
</pre>
<pre>Future Work:
    - git hooks
    - proxychains
</pre>