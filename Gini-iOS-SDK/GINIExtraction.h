/*
 *  Copyright (c) 2014, Gini GmbH.
 *  All rights reserved.
 */

/**
 * Data model for an extraction.
 */
@interface GINIExtraction : NSObject

/// Whether or not this extraction has some unsaved changes (e.g. after the value has been changed).
@property (readonly) BOOL isDirty;

/// The identifier for the extraction.
@property (readonly) NSString *name;

/// The extraction's value. Changing this value marks the extraction as dirty.
@property NSString *value;

/// The extraction's entity.
@property NSString *entity;

/// The extraction's box. Only available on some extractions. Changing this value marks the extraction as dirty.
@property NSDictionary *box;

/// The available candidates for this extraction (GINIExtraction instances).
@property NSArray *candidates;


/**
 * Factory to create a new GINIExtraction instance.
 *
 * @param name      The extraction's name.
 * @param value     The extraction's value.
 * @param entity    The extraction's entity.
 * @param box       The extraction's box.
 */
+ (instancetype)extractionWithName:(NSString *)name value:(NSString *)value entity:(NSString *)entity box:(NSDictionary *)box;

/**
 * The designated initializer.
 *
 * @param name      The extraction's name.
 * @param value     The extraction's value.
 * @param entity    The extraction's entity.
 * @param box       The extraction's box.
 */
- (instancetype)initWithName:(NSString *)name value:(NSString *)value entity:(NSString *)entity box:(NSDictionary *)box;

@end
