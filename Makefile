.PHONY: doctor test validate

doctor:
	./scripts/doctor.sh

test:
	cd packages/CoherenceKit && DEVELOPER_DIR=/Library/Developer/CommandLineTools swift build --build-system native
	cd packages/CoherenceKit && DEVELOPER_DIR=/Library/Developer/CommandLineTools swift run --build-system native CoherenceCoreVerification

validate:
	./scripts/validate.sh
