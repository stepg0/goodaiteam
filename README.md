# goodaiteam

* User1 takes 1 ticket
* User1 need to create new branch immediately
* User1 runs *Import_1*
* User1 develops in PowerApps
* User1 runs *Export_1 and Export_2* from *User1 branch* to bring the solution to git and create a pull request

Notes:
* Import_1 could take over the branch creation, however, how about the branch name? The user need to define the name manually
* Export_1 and Export_2 cannot be combined, because git somehow cannot find the folder even after re-checkout, see export_workflow.yml
