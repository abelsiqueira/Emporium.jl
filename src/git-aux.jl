# Prepend function names with git_
export git_has_modifications_to_stage
export git_has_staged_to_commit
export git_has_to_commit

"""
    git_has_modifications_to_stage()

Check for modified unstaged files.
"""
function git_has_modifications_to_stage()
  length(read(`git diff --stat`)) != 0
end

"""
    git_has_staged_to_commit()

Check for staged files
"""
function git_has_staged_to_commit()
  length(read(`git diff --staged --stat`)) != 0
end

"""
    git_has_to_commit()

Check for unstaged or staged modifications to commit.
Doesn't check for untracked files.
"""
function git_has_to_commit()
  git_has_modifications_to_stage() || git_has_staged_to_commit()
end