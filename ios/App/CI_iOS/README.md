# CI Scheme for iOS
This is the CI scheme for the iOS app. It is used to build and test the app in a continuous integration environment. All tests should be run in this scheme. Including Unit Tests, UI Tests, Snap shot tests, EndToEnd Tests. Everything. 

This way you you make sure that the app is always in a releasable state.

## How to use
1. Open the `amigos.xcworkspace` in Xcode.
2. Select the `CI_iOS` scheme from the scheme selector.
3. Run the tests by pressing `Cmd + U` or selecting `Product > Test` from the menu.
5. The tests will run and the results will be displayed in the Xcode console.

## adding new tests to CI scheme
To add new tests to the CI scheme, follow these steps:
1. Go the the scheme editor by selecting `Product > Scheme > Manage Scheme` from the menu.
2. Select the `CI_iOS` scheme from the list and click on the `Edit` button.
3. In the scheme editor, select the `Test` action from the left sidebar.
4. Click on the `CI_iOS` test plan in the list of test plans.
5. Click on the `+` button to add a new test target.
6. Select the test target you want to add from the list and click on the `Add` button.
7. Make sure the new test target is checked in the list of test targets.
9. Click on the `Close` button to save the changes.
10. Run the tests again (`Cmd + U`) to make sure the new tests are included in the CI_IOS test plan.

## Notes
It's not recommended to run CI scheme while developing. You should only run this locally once before a release or when you want to make sure that everything is working as expected to prevent as much build failures as possible.
