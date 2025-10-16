Contribution Guidelines for `matlab_owc`

This document explains how to contribute to [ArgoDMQC/matlab_owc](https://github.com/ArgoDMQC/matlab_owc). 
A write access is not necessary.
In the main repository  [ArgoDMQC/matlab_owc](https://github.com/ArgoDMQC/matlab_owc) :
    - master holds stable releases
    - develop is used for ongoing development work

### 1. Fork the repository
1. Go to [ArgoDMQC/matlab_owc](https://github.com/ArgoDMQC/matlab_owc).  
2. Click **Fork** (top-right) to create a copy under your account.

### 2. Clone your fork
```bash
git clone https://github.com/<your-username>/matlab_owc.git
cd matlab_owc
```
### 3. Add the upstream remote (the main repository)
 ```bash
git remote add upstream https://github.com/ArgoDMQC/matlab_owc.git
git remote -v
```
 ```bash
origin   →  https://github.com/<your-username>/matlab_owc.git (your fork)
upstream →  https://github.com/ArgoDMQC/matlab_owc.git (the main repository)
```
      
### 4. Create and track the develop branch

The develop branch will be used for ongoing contributions (instead of master).

```bash
git fetch upstream
git checkout -b develop upstream/develop
```

### 5.  Create a feature branch 

Always create a new branch for your work:

```bash
git checkout develop
git pull upstream develop
git checkout -b my-new-feature
 ```

### 6. Make your changes

Edit, add, or remove files as needed.
Commit your changes:

```bash
git add .
git commit -m "Fix: corrected error in function xxx"
 ```
### 7. Keep your branch updated

Sync regularly with upstream to avoid conflicts and always sync before pushing:

```bash
git checkout develop
git pull upstream develop
git checkout feature/my-new-feature
git rebase develop
```
### 8. Push to your fork
```bash
git push origin feature/my-new-feature
```
## 9. Open a Pull Request (PR)

- Go to your fork on GitHub.
- open a Pull Request.
    -> base repository: ArgoDMQC/matlab_owc
     -> base branch: develop
    -> compare branch: my-new-feature
- Write a  description of your changes and link to any related issues.

## 10. Code review & merge

- Your Pull Request will be rewied
- if changes are required → update your branch and push again.
- Once approved, it will be merged into develop.
