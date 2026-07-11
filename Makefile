.PHONY: doctor test validate

doctor:
	./scripts/doctor.sh

test:
	cd packages/swift/CoherenceKit && DEVELOPER_DIR=/Library/Developer/CommandLineTools swift build --build-system native
	cd packages/swift/CoherenceKit && DEVELOPER_DIR=/Library/Developer/CommandLineTools swift run --build-system native CoherenceCoreVerification

validate:
	./scripts/validate.sh
