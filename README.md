# Quizlet IT

### Instructions for use
1. Ensure standard security practices are in place (encryption, require password after sleep, screensaver enabled => 20 minutes, etc)
2. Confirm your Github account has been added to the Quizlet organization.
3. Add your SSH key to your account and enable SSO (if applicable).
4. Run the following code...
```shell
bash <(curl -Ls https://bit.ly/qz-setup)
```
5. Run the laptop-setup.sh script located in /opt/projects/quizlet-workstation/mac/
```shell
cd /opt/projects/quizlet-workstation/mac/
./laptop-setup.sh <quizlet email> <github user name>
```

Reference: https://quizlet.atlassian.net/wiki/spaces/QSD/pages/149258429/Setting+up+a+computer+to+access+Quizlet#SettingupacomputertoaccessQuizlet-ManualSetup(withoutJAMF)
