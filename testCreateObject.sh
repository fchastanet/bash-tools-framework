#!/bin/bash
FRAMEWORK_ROOT_DIR=.
source src/Log/__all.sh
source src/Crypto/uuidV4.sh
source src/Object/create.sh
source src/Options2/__all.sh

declare myFunction
Object::create myFunction \
    --type "Command" \
    --property-name "François"
declare myFunction2
Object::create myFunction2 \
    --array-list "a" \
    --type "Command2" \
    --property-name "François2" \
    --array-list "b" \
    --array-list "c"

echo "--------------------------------------------"
${myFunction} getProperty name
${myFunction2} getProperty name
${myFunction} getProperty name
${myFunction2} getProperty list

echo "------------------- setProperty -------------------------"
${myFunction} setProperty name "myFunctionFrançois3"
${myFunction} getProperty name
${myFunction2} setProperty name "myFunction2François3"
${myFunction2} getProperty name
echo -n "name2 "
${myFunction2} setProperty name2 "newProperty name2"
 
${myFunction2} getProperty name2

echo "--------------------------------------------"
Object::create myFunction2 \
    --function-name "argFunction2Overload" \
    --type "Command2Overload" \
    --property-name "François2Overload"
${myFunction2} getProperty name