//
//  XCTestCase.swift
//  OSCATemplateTests
//
//  Reviewed by Stephan Breidenbach on 10.02.22.
//  extended by Stephan Breidenbach on 30.05.22
//  Reviewed by Stephan Breidenbach on 21.06.22
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import Combine
import OSCANetworkService
@testable import OSCAPressReleases
import OSCATestCaseExtension
import XCTest

final class OSCAPressReleasesTests: XCTestCase {
  static let moduleVersion = "1.0.4"
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws -> Void {
    super.setUp()
    cancellables = []
  }// end override func setUp
  
  func testModuleInit() throws -> Void {
    let module: OSCAPressReleases = try make(config: .Development)
    XCTAssertNotNil(module)
    XCTAssertEqual(module.version, OSCAPressReleasesTests.moduleVersion)
    XCTAssertEqual(module.bundlePrefix, "de.osca.pressreleases")
    let bundle = OSCAPressReleases.bundle
    XCTAssertNotNil(bundle)
    XCTAssertNotNil(self.devPlistDict)
    XCTAssertNotNil(self.productionPlistDict)
  }// end func testModuleInit
  
  func testDownload() throws -> Void {
    var pressReleases: [OSCAPressRelease] = []
    var error: Error?
    
    let pressReleaseModule: OSCAPressReleases = try make(config: .Development)
    
    let expectation = self.expectation(description: "GetPressReleases")
    
    pressReleaseModule.getPressReleases(limit: 5)
      .sink { completion in          
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }
      } receiveValue: { result in
        switch result {
        case let .success(objects):
          pressReleases = objects
        case let .failure(encounteredError):
          error = encounteredError
        }
      }
      .store(in: &cancellables)
    
    waitForExpectations(timeout: 10)
    
    XCTAssertNil(error)
    XCTAssertTrue(pressReleases.count == 5)
  }// end func testDownload
  
  func testElasticSearchForPressReleases() throws -> Void {
    var pressReleases: [OSCAPressRelease] = []
    let queryString = "Solingen"
    var error: Error?
    
    let expectation = self.expectation(description: "elasticSearchForPressReleases")
    let module: OSCAPressReleases = try make(config: .Development)
    module.elasticSearch(for: queryString)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }// end switch case
      } receiveValue: { pressReleasesFromNetwork in
        pressReleases = pressReleasesFromNetwork
      }// end sink
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(error)
  }// end func testElasticSearchForPressReleases
}// end final class OSCAPressReleasesTests

extension OSCAPressReleasesTests {
  public func make(config: Keys.Configuration) throws -> OSCAPressReleasesDependencies {
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.pressreleases")
    var dependencies: OSCAPressReleasesDependencies?
    switch config {
    case .Development:
      let networkService = try makeDevNetworkService()
      dependencies = OSCAPressReleasesDependencies(
        networkService: networkService,
        userDefaults: userDefaults)
    case .Production:
      let networkService = try makeProductionNetworkService()
      dependencies = OSCAPressReleasesDependencies(
        networkService: networkService,
        userDefaults: userDefaults)
    }// end switch case
    guard let dependencies = dependencies else { throw XCTestCaseError.dataModuleDependencyError }
    return dependencies
  }// end public func make
  
  public func make(config: Keys.Configuration) throws -> OSCAPressReleases {
    let dependencies: OSCAPressReleasesDependencies = try make(config: config)
    var module: OSCAPressReleases?
    switch config {
    case .Development:
      // initialize module
      module = OSCAPressReleases.create(with: dependencies)
    case .Production:
      module = OSCAPressReleases.create(with: dependencies)
    }// end switch case
    guard let module = module else { throw XCTestCaseError.dataModuleError }
    return module
  }// end func make
}// end extension OSCAPressReleasesTests
#endif
