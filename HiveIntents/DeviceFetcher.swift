//
//  DeviceFetcher.swift
//  HiveShared
//
//  Created by Froggatt, James on 20/10/2019.
//  Copyright © 2019 James Froggatt. All rights reserved.
//

#if canImport(HiveSharedWatch)
import HiveSharedWatch
#else
import HiveShared
#endif

struct DeviceFetcher {
    var login: Login
    init(login: Login = Login()) {
        self.login = login
    }
    
    func getDevices(ofType contentType: APIContentType, success: @escaping (DeviceList) -> (), failure: @escaping (Error) -> ()) {
        do {
            let credentials = try LoginCredentials.savedCredentials()
            _ = login.login(credentials: credentials, contentType: contentType) {response in
                switch response {
                case .success(let loginInfo, _):
                    print("Success")
                    success(DeviceList(loginInfo: loginInfo))
                case .error(let error, _):
                    print("Failure: \(error)")
                    failure(error)
                }
            }
        } catch {
            print("Failure: \(error)")
            failure(error)
        }
    }
    
    func getProduct<ResultType>(_ viewModel: (DeviceList) -> ResultType?, success: @escaping (ResultType) -> (), failure: @escaping (Error, DeviceList?) -> ()) {
        getDevices(
            ofType: .product,
            success: {deviceList in
                guard let light = viewModel(deviceList) else {
                    return failure(DeviceFetchError.deviceResolution, deviceList)
                }
                success(light)
            },
            failure: {failure($0, nil)}
        )
    }
}


enum DeviceFetchError: String, LocalizedError {
    case deviceResolution = "Device not found"
    
    var errorDescription: String? {rawValue}
    var localizedDescription: String {rawValue}
}
