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
  cd ..
  cd config_files
  echo Inside the condition
  #TESTRUNID_LOCAL=$(yq -r '."$TENANT"."$ENVIRONMENT".$OS.testRunId' environment-map_TO_BE_DELETED.yaml)
  #yq -r '."jb-ph-mobile"."qa_b"."Android".testRunId' environment-map_TO_BE_DELETED.yaml
  #echo "yq -r '.${TENANT}.${ENVIRONMENT}.${OS}.testRunId' environment-map_TO_BE_DELETED.yaml"
  yq -r '.${TENANT}.${ENVIRONMENT}.${OS}.testRunId' environment-map_TO_BE_DELETED.yaml
  yq -r '."${TENANT}"."${ENVIRONMENT}"."${OS}".testRunId' environment-map_TO_BE_DELETED.yaml
  #yq -r '."${TENANT}"."${ENVIRONMENT}"."${OS}".testRunId' environment-map_TO_BE_DELETED.yaml
  export TESTRUNID_LOCAL=$(yq -r '."${TENANT}"."${ENVIRONMENT}"."${OS}".testRunId' environment-map.yaml)
  #TESTRUNID_LOCAL=$(yq -r '."[env(TENANT)]"."[env(ENVIRONMENT)]".[env(OS)].testRunId' environment-map_TO_BE_DELETED.yaml)
  echo NEWWWWWWWWWWWWW
  export TESTRUNID_LOCAL=$(yq -r '.'\"$TENANT'.'$ENVIRONMENT'.'$OS"\'.testRunId' environment-map.yaml)
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