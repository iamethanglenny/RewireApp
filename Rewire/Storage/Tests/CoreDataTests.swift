import Foundation
import CoreData
import XCTest

// Comprehensive tests for Core Data functionality
class CoreDataTests: XCTestCase {
    
    // Use the TestPersistenceController from CoreDataTest.swift
    var persistenceController: TestPersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        // Create a fresh in-memory Core Data stack for each test
        persistenceController = TestPersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        // Clean up after each test
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - DailyLog Tests
    
    func testCreateAndFetchDailyLog() {
        // Create a new DailyLog
        let dailyLog = DailyLog(context: context)
        dailyLog.id = UUID().uuidString
        dailyLog.date = Date()
        dailyLog.stayedClean = true
        dailyLog.note = "Test note"
        dailyLog.userId = "test-user"
        
        // Save the context
        XCTAssertNoThrow(try context.save(), "Failed to save context")
        
        // Fetch the DailyLog
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", dailyLog.id!)
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Expected 1 DailyLog, got \(results.count)")
            
            let fetchedLog = results.first!
            XCTAssertEqual(fetchedLog.id, dailyLog.id)
            XCTAssertEqual(fetchedLog.note, "Test note")
            XCTAssertEqual(fetchedLog.stayedClean, true)
            XCTAssertEqual(fetchedLog.userId, "test-user")
        } catch {
            XCTFail("Failed to fetch DailyLog: \(error)")
        }
    }
    
    func testDailyLogWithWellbeingRatings() {
        // Create a new DailyLog with WellbeingRatings
        let dailyLog = DailyLog(context: context)
        dailyLog.id = UUID().uuidString
        dailyLog.date = Date()
        dailyLog.stayedClean = true
        dailyLog.userId = "test-user"
        
        // Create WellbeingRatings
        let ratings = WellbeingRatings(context: context)
        ratings.id = UUID().uuidString
        ratings.mood = 4
        ratings.energy = 3
        ratings.sleep = 5
        ratings.cravingIntensity = 2
        
        // Establish relationship
        ratings.dailyLog = dailyLog
        dailyLog.wellbeingRatings = ratings
        
        // Save the context
        XCTAssertNoThrow(try context.save(), "Failed to save context")
        
        // Fetch the DailyLog with WellbeingRatings
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", dailyLog.id!)
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Expected 1 DailyLog, got \(results.count)")
            
            let fetchedLog = results.first!
            XCTAssertNotNil(fetchedLog.wellbeingRatings, "WellbeingRatings should not be nil")
            
            let fetchedRatings = fetchedLog.wellbeingRatings!
            XCTAssertEqual(fetchedRatings.mood, 4)
            XCTAssertEqual(fetchedRatings.energy, 3)
            XCTAssertEqual(fetchedRatings.sleep, 5)
            XCTAssertEqual(fetchedRatings.cravingIntensity, 2)
        } catch {
            XCTFail("Failed to fetch DailyLog with WellbeingRatings: \(error)")
        }
    }
    
    func testDailyLogWithCravings() {
        // Create a new DailyLog with Cravings
        let dailyLog = DailyLog(context: context)
        dailyLog.id = UUID().uuidString
        dailyLog.date = Date()
        dailyLog.stayedClean = true
        dailyLog.userId = "test-user"
        
        // Create Cravings
        let craving1 = CravingRecord(context: context)
        craving1.id = UUID().uuidString
        craving1.timestamp = Date()
        craving1.intensity = 3
        craving1.duration = 300 // 5 minutes
        craving1.trigger = "Stress"
        craving1.overcame = true
        
        let craving2 = CravingRecord(context: context)
        craving2.id = UUID().uuidString
        craving2.timestamp = Date().addingTimeInterval(3600) // 1 hour later
        craving2.intensity = 4
        craving2.duration = 600 // 10 minutes
        craving2.trigger = "Social situation"
        craving2.overcame = false
        
        // Establish relationships
        craving1.dailyLog = dailyLog
        craving2.dailyLog = dailyLog
        dailyLog.addToCravings(craving1)
        dailyLog.addToCravings(craving2)
        
        // Save the context
        XCTAssertNoThrow(try context.save(), "Failed to save context")
        
        // Fetch the DailyLog with Cravings
        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", dailyLog.id!)
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Expected 1 DailyLog, got \(results.count)")
            
            let fetchedLog = results.first!
            XCTAssertNotNil(fetchedLog.cravings, "Cravings should not be nil")
            
            let fetchedCravings = fetchedLog.cravings as? Set<CravingRecord>
            XCTAssertEqual(fetchedCravings?.count, 2, "Expected 2 cravings, got \(fetchedCravings?.count ?? 0)")
            
            // Check if cravings have correct properties
            let overcomeCravings = fetchedCravings?.filter { $0.overcame }
            XCTAssertEqual(overcomeCravings?.count, 1, "Expected 1 overcome craving")
            
            let notOvercomeCravings = fetchedCravings?.filter { !$0.overcame }
            XCTAssertEqual(notOvercomeCravings?.count, 1, "Expected 1 not overcome craving")
        } catch {
            XCTFail("Failed to fetch DailyLog with Cravings: \(error)")
        }
    }
    
    // MARK: - Challenge Tests
    
    func testCreateAndFetchChallenge() {
        // Create a new Challenge
        let challenge = Challenge(context: context)
        challenge.id = UUID().uuidString
        challenge.title = "Test Challenge"
        challenge.desc = "This is a test challenge"
        challenge.difficulty = "Medium"
        challenge.daysToComplete = 7
        challenge.progress = 0.5
        
        // Save the context
        XCTAssertNoThrow(try context.save(), "Failed to save context")
        
        // Fetch the Challenge
        let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", challenge.id!)
        
        do {
            let results = try context.fetch(fetchRequest)
            XCTAssertEqual(results.count, 1, "Expected 1 Challenge, got \(results.count)")
            
            let fetchedChallenge = results.first!
            XCTAssertEqual(fetchedChallenge.id, challenge.id)
            XCTAssertEqual(fetchedChallenge.title, "Test Challenge")
            XCTAssertEqual(fetchedChallenge.desc, "This is a test challenge")
            XCTAssertEqual(fetchedChallenge.difficulty, "Medium")
            XCTAssertEqual(fetchedChallenge.daysToComplete, 7)
            XCTAssertEqual(fetchedChallenge.progress, 0.5)
        } catch {
            XCTFail("Failed to fetch Challenge: \(error)")
        }
    }
    
    // Add more tests for other entities and relationships as needed
}

// Run the tests
func runCoreDataTests() {
    let testSuite = XCTestSuite.default
    let testCase = CoreDataTests()
    testSuite.addTest(testCase)
    
    let testResult = XCTestRun(test: testSuite)
    testSuite.perform(testResult)
    
    print("Tests run: \(testResult.executionCount)")
    print("Tests failed: \(testResult.failureCount)")
    print("Test duration: \(testResult.totalDuration)")
} 