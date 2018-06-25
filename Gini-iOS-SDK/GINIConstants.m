//
//  GINIConstants.m
//  Gini-iOS-SDK
//
//  Created by Gini GmbH on 4/25/18.
//

#import <Foundation/Foundation.h>
#import "GINIConstants.h"

// Content Type

NSString* const GINIContentApplicationJson = @"application/json";
NSString* const GINIContentApplicationXml = @"application/xml";
NSString* const GINIContentJsonV1 = @"application/vnd.gini.v1+json";
NSString* const GINIContentXmlV1 = @"application/vnd.gini.v1+xml";
NSString* const GINIContentJsonV2 = @"application/vnd.gini.v2+json";
NSString* const GINIContentXmlV2 = @"application/vnd.gini.v2+xml";
NSString* const GINICompositeJsonV2 = @"application/vnd.gini.v2.composite+json";
NSString* const GINIPartialTypeV2 = @"application/vnd.gini.v2.partial+%@";
NSString* const GINIIncubatorJson = @"application/vnd.gini.incubator+json";
NSString* const GINIIncubatorXml = @"application/vnd.gini.incubator+xml";


// Extraction keys

NSString* const ExtractionAmountToPayKey = @"amountToPay";
NSString* const ExtractionPaymentReferenceKey = @"paymentReference";
NSString* const ExtractionPaymentRecipientKey = @"paymentRecipient";
NSString* const ExtractionIbanKey = @"iban";
NSString* const ExtractionBicKey = @"bic";
NSString* const ExtractionPaymentPurposeKey = @"paymentPurpose";
