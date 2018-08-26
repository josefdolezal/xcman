build:
	swift build

release:
	swift build --disable-sandbox --configuration release

clean:
	swift package clean

proj:
	swift package generate-xcodeproj