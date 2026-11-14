echo 'From shell script'
echo Test run id from parameter is $TESTRUNID
echo Tenant from parameter is $TENANT
echo ENVIRONMENT from parameter is $ENVIRONMENT
echo OS from parameter is $OS
echo Project Token from parameter is $PROJECT_TOKEN
echo Last parameter is $6
TESTRUNID_LOCAL=$TESTRUNID
echo TESTRUNID_LOCAL is $TESTRUNID_LOCAL
if [ $TESTRUNID = 'Default' ]
then
  echo 'TESTRUNID is Default'
  if [ $TENANT = 'jb-ph-mobile' ]
  then
    echo 'Tenant is jb-ph-mobile'
    if [ $ENVIRONMENT = 'qa-b' ]
    then
        echo 'Environment is qa-b'
        if [ $OS = 'iOS' ]
        then
          echo 'OS is iOS'
          TESTRUNID_LOCAL=632303
        elif [ $OS = 'Android' ]
        then
          echo 'OS is Android'
          TESTRUNID_LOCAL=632303
        fi
    fi
  elif [ $TENANT = 'grn-ph-mobile' ]
  then
    echo 'Tenant is grn-ph-mobile'
  fi 
else
  echo 'Proper TESTRUNID is provided'
fi

echo Final test run id is $TESTRUNID_LOCAL

cd ..

if [ $6 = 'download' ]
then
  echo Dowloading tests
  hiptest-publisher -c hiptest-publisher.conf --token=$PROJECT_TOKEN --filename-pattern=%s.robot --test-run-id $TESTRUNID_LOCAL --without=actionwords -v
fi

if [ $6 = 'push' ]
then
  echo Pushing results
  pwd
  hiptest-publisher --config-file hiptest-publisher.conf --token=$PROJECT_TOKEN --push results/output.xml --test-run-id $TESTRUNID_LOCAL --push-format robot
fi