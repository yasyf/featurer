# Featurer
### Automatic Staging of Github Feature Branches

## What is Featurer?

Featurer is a server platform that acts as a hub for Docker instances which represent feature branches on Github repos. Using feature branches for short-term goals is a common "social git" tactic employed today, and one of my biggest personal frustrations with this method is the friction involved in viewing and testing someone's proposed changes in a production-like environment.

Featurer solves this issue by monitoring the repos you register, looking for new or updated pull requests. Each branch with a corresponding PR is cloned and launched in a new Docker instance on the server. Staged copies of branches are updated when new commits are pushed, and a comment is made on each PR with a link to the staged branch, as well as a screenshot. You can see a demo [here](https://github.com/yasyf/flask-start/pull/1).

When a PR is closed or new commits are pushed, the old instance is automatically cleaned up and disposed of, meaning a small server running Featurer can service many, many branches.

To get up and running, you simply have to deploy Featurer to a box that is capable of running a Rails app, and has Docker installed. Register repos by creating new `Repo` models, as below. You can pass in the location of the Dockerfile in the repo, as well as any environment secrets that need to be present when the branch is staged.

## Example

This was a demo given in realtime. The results can be seen [here](https://github.com/yasyf/flask-start/pull/1).

```ruby
r = Repo.new user: 'yasyf', name: 'flask-start', dockerfile: 'Dockerfile', secrets: {DEV: true, SK: '123abc'}
r.save
```

Start with `rails s` and visit `http://localhost:3000/branch/yasyf/flask-start/test_branch`. You will see some log output as the Docker image is build and started. After a minute or so, your branch will be ready, and there should be a comment on the Github repo!

![Featurer Output](https://s3.amazonaws.com/f.cl.ly/items/2u3g0Y192F3w2q0c3m1b/Screen%20Shot%202015-02-22%20at%208.24.46%20AM.png)
