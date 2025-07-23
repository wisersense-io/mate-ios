import Foundation

// MARK: - Dependency Injection Container
class DIContainer: ObservableObject {
    
    // MARK: - Singletons
    static let shared = DIContainer()
    
    // MARK: - Storage Services
    private lazy var tokenStorageService: TokenStorageServiceProtocol = {
        UserDefaultsTokenStorageService()
    }()
    
    private lazy var organizationStorageService: OrganizationStorageService = {
        OrganizationStorageService()
    }()
    
    // MARK: - Network Data Sources
    private lazy var authNetworkDataSource: AuthNetworkDataSourceProtocol = {
        AuthNetworkDataSource()
    }()
    
    private lazy var homeNetworkDataSource: HomeNetworkDataSourceProtocol = {
        HomeNetworkDataSource()
    }()
    
    private lazy var dashboardNetworkDataSource: DashboardNetworkDataSourceProtocol = {
        DashboardNetworkDataSource(tokenStorage: tokenStorageService)
    }()
    
    private lazy var organizationNetworkDataSource: OrganizationNetworkDataSource = {
        OrganizationNetworkDataSource(tokenStorage: tokenStorageService)
    }()
    
    private lazy var profileNetworkDataSource: ProfileNetworkDataSourceProtocol = {
        ProfileNetworkDataSource()
    }()
    
    private lazy var systemNetworkDataSource: SystemNetworkDataSourceProtocol = {
        SystemNetworkDataSource(tokenStorage: tokenStorageService)
    }()
    
    private lazy var systemHistoryNetworkDataSource: SystemHistoryNetworkDataSourceProtocol = {
        SystemHistoryNetworkDataSource(tokenStorage: tokenStorageService)
    }()
    
    // MARK: - Repositories
    private lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepository(
            networkDataSource: authNetworkDataSource,
            tokenStorage: tokenStorageService
        )
    }()
    
    private lazy var homeRepository: HomeRepositoryProtocol = {
        HomeRepository(networkDataSource: homeNetworkDataSource)
    }()
    
    private lazy var dashboardRepository: DashboardRepositoryProtocol = {
        DashboardRepository(networkDataSource: dashboardNetworkDataSource)
    }()
    
    private lazy var organizationRepository: OrganizationRepositoryProtocol = {
        OrganizationRepository(
            networkDataSource: organizationNetworkDataSource
        )
    }()
    
    private lazy var profileRepository: ProfileRepositoryProtocol = {
        ProfileRepository(networkDataSource: profileNetworkDataSource)
    }()
    
    private lazy var systemRepository: SystemRepositoryProtocol = {
        SystemRepository(networkDataSource: systemNetworkDataSource)
    }()
    
    private lazy var systemHistoryRepository: SystemHistoryRepositoryProtocol = {
        SystemHistoryRepository(networkDataSource: systemHistoryNetworkDataSource)
    }()
    
    // MARK: - Use Cases
    private lazy var loginUseCase: LoginUseCaseProtocol = {
        LoginUseCase(authRepository: authRepository)
    }()
    
    private lazy var forgotPasswordUseCase: ForgotPasswordUseCaseProtocol = {
        ForgotPasswordUseCase(authRepository: authRepository)
    }()
    
    private lazy var verificationCodeUseCase: VerificationCodeUseCaseProtocol = {
        VerificationCodeUseCase(authRepository: authRepository)
    }()
    
    private lazy var homeUseCase: HomeUseCaseProtocol = {
        HomeUseCase(homeRepository: homeRepository, organizationUseCase: organizationUseCase)
    }()
    
    private lazy var dashboardUseCase: DashboardUseCaseProtocol = {
        DashboardUseCase(dashboardRepository: dashboardRepository, organizationUseCase: organizationUseCase)
    }()
    
    private lazy var organizationUseCase: OrganizationUseCaseProtocol = {
        OrganizationUseCase(organizationRepository: organizationRepository, organizationStorage: organizationStorageService)
    }()
    
    private lazy var profileUseCase: ProfileUseCaseProtocol = {
        ProfileUseCase(profileRepository: profileRepository)
    }()
    
    lazy var systemUseCase: SystemUseCase = {
        SystemUseCase(systemRepository: systemRepository)
    }()
    
    private lazy var systemHistoryUseCase: SystemHistoryUseCaseProtocol = {
        SystemHistoryUseCase(
            repository: systemHistoryRepository
        )
    }()
    
    // MARK: - User Session
    private lazy var userSessionManager: UserSessionManager = {
        UserSessionManager.shared
    }()
    
    private init() {}
    
    // MARK: - Public Accessors
    var loginUseCaseInstance: LoginUseCaseProtocol {
        return loginUseCase
    }
    
    var forgotPasswordUseCaseInstance: ForgotPasswordUseCaseProtocol {
        return forgotPasswordUseCase
    }
    
    var verificationCodeUseCaseInstance: VerificationCodeUseCaseProtocol {
        return verificationCodeUseCase
    }
    
    var homeUseCaseInstance: HomeUseCaseProtocol {
        return homeUseCase
    }
    
    var dashboardUseCaseInstance: DashboardUseCaseProtocol {
        return dashboardUseCase
    }
    
    var organizationUseCaseInstance: OrganizationUseCaseProtocol {
        return organizationUseCase
    }
    
    var profileUseCaseInstance: ProfileUseCaseProtocol {
        return profileUseCase
    }
    
    var systemUseCaseInstance: SystemUseCase {
        return systemUseCase
    }
    
    var systemHistoryUseCaseInstance: SystemHistoryUseCaseProtocol {
        return systemHistoryUseCase
    }
    
    var userSessionManagerInstance: UserSessionManager {
        return userSessionManager
    }
    
    // MARK: - Factory Methods for Legacy Usage
    
    func makeLoginUseCase() -> LoginUseCaseProtocol {
        return loginUseCase
    }
    
    func makeForgotPasswordUseCase() -> ForgotPasswordUseCaseProtocol {
        return forgotPasswordUseCase
    }
    
    func makeVerificationCodeUseCase() -> VerificationCodeUseCaseProtocol {
        return verificationCodeUseCase
    }
    
    func makeHomeUseCase() -> HomeUseCaseProtocol {
        return homeUseCase
    }
    
    func makeDashboardUseCase() -> DashboardUseCaseProtocol {
        return dashboardUseCase
    }
    
    func makeOrganizationUseCase() -> OrganizationUseCaseProtocol {
        return organizationUseCase
    }
    
    func makeProfileUseCase() -> ProfileUseCaseProtocol {
        return profileUseCase
    }
    
    // MARK: - Auth State
    func isUserLoggedIn() -> Bool {
        return authRepository.isLoggedIn()
    }
    
    func getCurrentToken() -> AuthToken? {
        return authRepository.getStoredToken()
    }
    
    func logout() {
        authRepository.clearToken()
        UserSessionManager.shared.clearUser()
    }
} 
