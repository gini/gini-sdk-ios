cd $TRAVIS_BUILD_DIR 

git clone --branch=gh-pages https://$GH_TOKEN@github.com/gini/gini-sdk-ios.git gh-pages > /dev/null > /dev/null

cd gh-pages
git rm -rf *
cp -Rf $TRAVIS_BUILD_DIR/docs/html/* .
git add -f .
git commit -m "Update SDK documentation (Travis build $TRAVIS_BUILD_NUMBER)"
git push -fq origin gh-pages > /dev/null

