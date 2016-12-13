#!/usr/bin/env bash

archs=( i386 x86_64 armv7 armv7s arm64 )
sdks=( \
	iphonesimulator iphonesimulator \
	iphoneos iphoneos iphoneos \
)

min_sdk=8.0.0


function build_lib {

	libname=$1
	proj_path=$2
	tgt=$3
	tmp_dir_base=$4
	out_path=$5

	echo "*** Building Lib: ${libname} Target: ${tgt} ***"

	mkdir -p $out_path

	for i in ${!archs[@]}; do

		arch=${archs[i]}
		sdk=${sdks[i]}

		echo "----------- Building: Arch:${arch} SDK:${sdk} : MIN_SDK:${min_sdk}  -----------" 
		xcodebuild -project "${proj_path}" -sdk ${sdk} -arch $arch -target "${tgt}" -mios-version-min=${min_sdk}

		# copy to out dir
		tmp_dir=$tmp_dir_base$sdk
		out_dir_arch=$out_path$arch


		rm -rf $out_dir_arch/*
		mkdir -p $out_dir_arch

		cp $tmp_dir/$libname $out_dir_arch/$libname
	done
	
	# create universal lib
	univ_dir=$out_path/universal

	rm -rf $univ_dir/*
	mkdir -p $univ_dir

	echo "----------- Building universal lib at: ${univ_dir} -----------"

	all_libs=$(find $out_path* -name "${libname}")
	xcrun lipo -create $all_libs -o $univ_dir/$libname

	echo
	echo Done!!
	echo
}

build_lib libogg.a macosx/Ogg.xcodeproj "libogg (static)" macosx/build/Release- bin_ios/

