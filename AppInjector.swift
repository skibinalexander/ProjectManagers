//
//  AppInjector.swift
//  Vezu
//
//  Created by Пользователь on 06.02.2019.
//  Copyright © 2019 VezuAppDevTeam. All rights reserved.
//

import Foundation
import Swinject

class AppInjector {
    
    //  MARK: Static
    
    static let shared: AppInjector = AppInjector()
    
    //
    
    let global = Container()
    
    //  MARK: Lifecycle
    
    init() {
        registrationServices()
        registrationStartSignModules()
        registrationDestinationMapModules()
        registrationProfileTabBarModules()
    }
    
    //  MARK: Injection
    
    private func registrationProfileTabBarModules() {
        global.register(UpdateProfileRouter.self) { _ in
            let router = UpdateProfileRouter(inParams: [UpdateProfileRouterParametersKeys.keyPrivacyService.rawValue : self.global.resolve(PrivacyService.self),
                                                        UpdateProfileRouterParametersKeys.keyUsersService.rawValue : self.global.resolve(UsersService.self),
                                                        UpdateProfileRouterParametersKeys.keyAdressService.rawValue : self.global.resolve(AdressService.self)])
            router.assemblyModule()
            return router
        }
    }
    
    private func registrationStartSignModules() {
        
        global.register(StartSignRouter.self) { _ in
            let router = StartSignRouter(inParams: [StartSignRouterParametersKeys.keyPresentModule.rawValue : self.global.resolve(StartSignNavigationRouter.self)])
            router.assemblyModule()
            return router
        }
        
        global.register(StartSignNavigationRouter.self) { _ in
            let router = StartSignNavigationRouter(inParams: [StartSignNavigationRouterParametersKeys.keyRootModule.rawValue : self.global.resolve(SignInPhoneRouter.self)])
            router.assemblyModule()
            return router
        }
        
        global.register(SignInPhoneRouter.self) { _ in
            let router = SignInPhoneRouter(inParams: [SignInPhoneRouterParametersKeys.keyPrivacyService.rawValue : self.global.resolve(PrivacyService.self),
                                                        SignInPhoneRouterParametersKeys.keyUsersService.rawValue : self.global.resolve(UsersService.self),
                                                        SignInPhoneRouterParametersKeys.keySignInCodeModule.rawValue : self.global.resolve(SignInCodeRouter.self)])
            router.assemblyModule()
            
            return router
        }
        
        global.register(SignInCodeRouter.self) { _ in
            let router = SignInCodeRouter(inParams: [SignInCodeRouterParametersKeys.keyPrivacyService.rawValue : self.global.resolve(PrivacyService.self),
                                                     SignInCodeRouterParametersKeys.keyUsersService.rawValue : self.global.resolve(UsersService.self)])
            router.assemblyModule()
            return router
        }
        
    }
    
    private func registrationDestinationMapModules() {
        
        global.register(DestinationMapContainerRouter.self) { _ in
            let router = DestinationMapContainerRouter(inParams: [DestinationMapContainerRouterParametersNames.primaryModule.rawValue : self.global.resolve(DestinationMapRouter.self),
                                                                    DestinationMapContainerRouterParametersNames.drawerModule.rawValue : self.global.resolve(DestinationMapInfoRouter.self)])
            router.assemblyModule()
            return router
        }
        
        global.register(DestinationMapRouter.self) { _ in
            let router = DestinationMapRouter()
            router.assemblyModule()
            return router
        }
        
        global.register(DestinationMapInfoRouter.self) { _ in
            let router = DestinationMapInfoRouter()
            router.assemblyModule()
            return router
        }
        
        global.register(NewOrderFormRouter.self) { _ in
            let router = NewOrderFormRouter(inParams: [NewOrderFormRouterParametersNames.adresseService.rawValue : self.global.resolve(AdressService.self)])
            router.assemblyModule()
            return router
        }
        
    }
    
    //  MARK: RegisterServices
    
    private func registrationServices() {
        
        global.register(PrivacyService.self) { _ in
            return PrivacyService.service
        }
        
        global.register(UsersService.self) { _ in
            let service = UsersService.service
            service.set(fb_token: self.global.resolve(PrivacyService.self)?.profile.auth.fb_auth_profile.fb_token)
            service.set(auth_token: self.global.resolve(PrivacyService.self)?.profile.auth.auth_profile.auth_token)
            return service
        }
        
        global.register(AdressService.self) { _ in
            let service = AdressService.service
            service.set(auth_token: self.global.resolve(PrivacyService.self)?.profile.auth.auth_profile.auth_token)
            return service
        }
        
    }
}
