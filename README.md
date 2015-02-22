## Featurer

Comments on GitHub PRs with links to Docker containers with that branch's changes.

### Example

This was a demo given in realtime. The results can be seen [here](https://github.com/yasyf/flask-start/pull/1).

```ruby
r = Repo.new user: 'yasyf', name: 'flask-start', dockerfile: 'Dockerfile', secrets: {DEV: true, SK: '123abc'}
r.save
```

Start with `rails s` and visit `http://localhost:3000/branch/yasyf/flask-start/test_branch`.
