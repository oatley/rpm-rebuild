#!/bin/bash

USERNAME=oatley

DIR=/home/${USERNAME}/Workspace/leaf/autopackage
WORKDIR=${DIR}/working
COMPLETEDIR=${DIR}/completed
SRPMDIR=${DIR}/packages-to-build
DONEDIR=${DIR}/packages-not-to-build

FAILED=""
SUCCESS=""
FAILEDCOUNT=0
SUCCESSCOUNT=0


# Initial setup
mkdir -p ${WORKDIR} ${COMPLETEDIR} ${SRPMDIR} ${DONEDIR}

cd  ${SRPMDIR}

for rpmfile in *.src.rpm; do
	
	PKG=$(sed 's/\.el7.*//' <<<$rpmfile)
	mkdir -p ${WORKDIR}/${PKG}/rpmbuild
	rpm -i --root=${WORKDIR}/${PKG}/rpmbuild/ ${SRPMDIR}/${PKG}*
	sudo yum-builddep -y ${WORKDIR}/${PKG}/rpmbuild/home/${USERNAME}/rpmbuild/SPECS/*.spec
	
	# Build the rpm locally
	rpmbuild -D "%_topdir ${WORKDIR}/${PKG}/rpmbuild/home/username/rpmbuild/" -ba ${WORKDIR}/${PKG}/rpmbuild/home/oatley/rpmbuild/SPECS/*.spec
	err=$?
	if [ "${err}" == "0" ]; then
		echo "SUCCESS ============================="
		SUCCESS="${SUCCESS} ${PKG}"
		((SUCCESSCOUNT++))
		cp ${WORKDIR}/${PKG}/rpmbuild/home/${USERNAME}/rpmbuild/RPMS/*/* ${COMPLETEDIR}/${PKG}	
		cp ${WORKDIR}/${PKG}/rpmbuild/home/${USERNAME}/rpmbuild/SRPMS/* ${COMPLETEDIR}/${PKG}	
		mv ${SRPMDIR}/${PKG}* ${DONEDIR}/
	else
		echo "FAILED ============================="
		FAILED="${FAILED} ${PKG}"
		((FAILEDCOUNT++))
	fi
	
done

echo ""
echo "=====SUCCESS====="
echo "${SUCCESS}"
echo "=====FAILED====="
echo "${FAILED}"
echo "=====STATS====="
echo "completed: ${COMPLETECOUNT}"
echo "failed: ${FAILCOUNT}"

