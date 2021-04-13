# Quick introduction to git and GitHub

Git does version control. Whether it's code, a manuscript or any other collection of documents, the process from start
to finish is rarely linear. You will want to add some things, remove others, fix mistakes, try out some crazy new idea,
change your mind, change it again. During all of this, you want to work with clean versions that only contain whatever
is relevant to that particular version, but also be able to go back to earlier versions, retrieve what has been removed
at some point, and make a version based on two or more others. A common way to do this is making copies of your work, in
different directories and/or with different filenames, but it quickly becomes unmanageable. If you fix a typo in one
version, how does that relate to other versions that had that typo? Those results you showed at that conference, what
code did you use to generate it and what was it you have changed since? And why?

And now imagine you are not the only one working on this project...

This is what git is for. You can use it locally to create many versions of the same files and folders, each with their
own history and rationale, they may go their separate paths and then come together to take advantage of the improvements
from both versions, making a new version without losing track of what was done when and why.

So, git lets you

- Keep track of changes (both the what and why)
- Revert changes
- Try things out without ruining what works
- Backup all of the above
- Stop using silly filenames like "final_version_3b_for_real_this_time"
- Collaborate with others
- Fork projects, inheriting all of the above

*GitHub* is not git, but a way (the most common one) to connect this workflow to the internet so that it is safely
archived and can be worked on by and with others.

### Using git locally

Let's set up a local git and stay organized. I'll assume you have git installed and know how to open a terminal, but
that's about it.

`init` makes a directory ready for being version-controlled by git. Go to the root directory of your project, however
you wish to define "project" in your work, in a terminal. This directory can be empty if you're starting something new,
or may already contain a bunch of files from what you've done so far. Type `git init` and hit enter and voilà, the
directory is now git ready. It won't look any different, but you can type `git status` to see it really is git-ready.

Now, if you don't have any project files yet, start doing some work to create some. A description is generally a good
start. Now that you have some files, it is time to tell git that you want these files to be part of the git workflow. To
do this, you add a file to git by typing `git add example.txt` or just `git add .` to add all files and their changes to
git. Typing `git status` tells you these files have been added but not yet committed (saved to a next version of your
project). Let's do that now.

Committing is done by typing `git commit -m "Commit message here"`. The -m stands for "message", these are important (so
important they are mandatory) to keep track of what is new in this version. So if you add a reference to a paper, write
that you did so in this message. It is good practice keeping them short and descriptive.

Now that this is done, all your files are part of that new version of your project. Running `git status` confirms that
there is nothing more to be done until you have worked more on your project files themselves. Running `git log` shows
that the new commit has been added, telling you who (you) did what and why (the message).

After working on your files, you again have to tell git that these are changes that should be part of your next commit.
You can do so again by using `git add`, but there is also a shortcut for the common task of running `git add .` and
then `git commit -m "Message here"`: `git commit -a -m "Message here"` adds all changes to the files and commits those
in one go.

If you want, you can branch off a copy of your project to try something new without your experiment messing with your
current (master) branch. You can switch back and forth between these branches to edit them however you want, and commit
things along the way. You can branch out any stage of the project at any time, either from the main branch or from
sub-branches. You can use `git branch new_branch_name` and then `git checkout new_branch_name` to create a new branch
from the one you are currently in, or do `git checkout -b new_branch_name` to create and switch in one command.

In this new branch you can add, change, and delete files and directories without that affecting the original branch.
Running `git checkout master` will get you back to the master branch where everything is as it was. You can change
things there too, without that affection the derived branch. They live their own lives unaware of each other.

But at some point you may actually want to bring the changes you made in the sub-branch into the one it was derived
from, such as when the thing you were trying worked, and now should replace the older version. To do this, go to the
target branch (main, in this example): `git checkout main`. By running `git merge new_branch_name` the changes from that
branch will be incorporated into the main one. If you had changed anything in the main branch after the split, this will
produce a conflict; git can't know which of the two versions of a line of code you want, as both are newer than the
original from the time of the branching. In that case git will warn you of such conflicts, and it will show in the code
as:

```
<<<<<<< HEAD
This is a line that I added while working in the master
=======
This is a line I added to the new branch
>>>>>>> new_branch_name
```

It is up to you to resolve such conflicts. It's your project. Don't forget to add and commit the changes you make when
resolving the conflict.

Now that you have merged the branch into the master branch, you can remove the new branch if you want
to: `git branch -d new_branch_name`.

A final note is that there are files that you may not want git to control, certainly things like encryption keys or
other confidential files, but also log files or generated output. To make sure git does not add those even when
running `git add .` or `git commit -a`, simply create a file called `.gitignore`. You can open this file and add
patterns for files you want git to ignore on separate lines, such as `passwords.txt` but also using wildcards such
as `*.log` or `output/*`

**Is there anything you are missing in this guide? Let me know or, better yet, open an issue right here on GitHub.**
