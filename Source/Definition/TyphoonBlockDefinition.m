////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2016, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import "TyphoonBlockDefinition.h"
#import "TyphoonBlockDefinition+Internal.h"
#import "TyphoonDefinition+Internal.h"
#import "TyphoonBlockDefinitionController.h"

@interface TyphoonBlockDefinition ()

@property (nonatomic, assign) BOOL hasInitializerBlock;

@end


@implementation TyphoonBlockDefinition

+ (id)withClass:(Class)clazz initializer:(TyphoonBlockDefinitionInitializerBlock)initializer
                              injections:(TyphoonBlockDefinitionInjectionsBlock)injections
                           configuration:(TyphoonDefinitionBlock)configuration
{
    TyphoonBlockDefinitionController *controller = [TyphoonBlockDefinitionController currentController];
    
    switch (controller.route) {
        case TyphoonBlockDefinitionRouteInvalid:
        {
            [NSException raise:NSInternalInconsistencyException
                        format:@"TyphoonBlockDefinition cannot be used directly. You should only use it inside TyphoonAssembly methods."];
            return nil;
        }
            
        case TyphoonBlockDefinitionRouteConfiguration:
        {
            TyphoonBlockDefinition *definition = [[TyphoonBlockDefinition alloc] initWithClass:clazz key:nil];
            definition.hasInitializerBlock = initializer != nil;
            if (configuration) {
                configuration(definition);
            }
            return definition;
        }
            
        case TyphoonBlockDefinitionRouteInitializer:
        {
            if (!initializer) {
                [NSException raise:NSInternalInconsistencyException
                            format:@"TyphoonBlockDefinition is supposed to have an initializer block at this point."];
            }
            
            id instance = initializer();
            return instance;
        }
            
        case TyphoonBlockDefinitionRouteInjections:
        {
            if (injections && controller.instance) {
                injections(controller.instance);
            }
            return controller.instance;
        }
    }
}

- (TyphoonMethod *)initializer {
    return nil;
}

- (BOOL)isInitializerGenerated {
    return !self.hasInitializerBlock;
}

@end