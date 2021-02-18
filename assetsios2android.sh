#!/bin/sh

mkdir -p ./androidexport/drawable-hdpi	
	for file in $(find ./Assets.xcassets -name '*.png' ! -name '*@2x.png' ! -name '*@3x.png') 
	do
		name=${file##*/}
		base=${name%.png}		
		printf "%s\n" "$file"
		cp "$file" "./androidexport/drawable-hdpi/a$base.png"
	done	
mkdir -p ./androidexport/drawable-xhdpi	
	for file in $(find ./Assets.xcassets -name '*@2x.png') 
	do
		name=${file##*/}
		base=${name%@2x.png}		
		printf "%s\n" "$file"
		cp "$file" "./androidexport/drawable-xhdpi/a$base.png"
	done	
	mkdir -p ./androidexport/drawable-xxhdpi	
		for file in $(find ./Assets.xcassets -name '*@3x.png') 
		do
			name=${file##*/}
			base=${name%@3x.png}		
			printf "%s\n" "$file"
			cp "$file" "./androidexport/drawable-xxhdpi/a$base.png"
		done	
