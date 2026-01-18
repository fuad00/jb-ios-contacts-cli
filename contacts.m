/*
 * contacts.m - CLI tool for iOS Contact Management
 * Usage:
 *   ./contacts -d                   (Delete all)
 *   ./contacts -i <num1> <num2>...  (Import numbers)
 */

@import Foundation;
@import Contacts;

// --- Helper Functions ---

void printMsg(NSString *msg) {
    printf("%s\n", [msg UTF8String]);
}

BOOL deleteAllContacts() {
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *request = [[CNSaveRequest alloc] init];
    NSError *error = nil;
    
    NSArray *keys = @[CNContactIdentifierKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    __block int count = 0;
    
    BOOL fetchSuccess = [store enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        CNMutableContact *mutableContact = [contact mutableCopy];
        [request deleteContact:mutableContact];
        count++;
    }];
    
    if (!fetchSuccess) {
        printMsg([NSString stringWithFormat:@"Error fetching contacts: %@", error.localizedDescription]);
        return NO;
    }
    
    if (count == 0) {
        printMsg(@"Address book is already empty.");
        return YES;
    }
    
    printMsg([NSString stringWithFormat:@"Found %d contacts. Deleting...", count]);
    
    BOOL saveSuccess = [store executeSaveRequest:request error:&error];
    if (saveSuccess) {
        printMsg(@"SUCCESS: All contacts deleted.");
        return YES;
    } else {
        printMsg([NSString stringWithFormat:@"ERROR deleting: %@", error.localizedDescription]);
        return NO;
    }
}

BOOL importContacts(NSArray<NSString *> *phoneNumbers) {
    if (phoneNumbers.count == 0) {
        printMsg(@"Error: No phone numbers provided for import.");
        return NO;
    }

    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *request = [[CNSaveRequest alloc] init];
    
    int importedCount = 0;
    
    for (NSString *phoneRaw in phoneNumbers) {
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        
        // Use last 4 digits for name or "Imported" if short
        NSString *suffix = (phoneRaw.length > 4) ? [phoneRaw substringFromIndex:phoneRaw.length - 4] : @"User";
        contact.givenName = @"Bot";
        contact.familyName = suffix;
        
        CNPhoneNumber *phoneObj = [CNPhoneNumber phoneNumberWithStringValue:phoneRaw];
        contact.phoneNumbers = @[[CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:phoneObj]];
        
        [request addContact:contact toContainerWithIdentifier:nil];
        importedCount++;
    }
    
    printMsg([NSString stringWithFormat:@"Saving %d contacts...", importedCount]);
    
    NSError *error = nil;
    BOOL success = [store executeSaveRequest:request error:&error];
    
    if (success) {
        printMsg(@"SUCCESS: Contacts imported.");
        return YES;
    } else {
        printMsg([NSString stringWithFormat:@"ERROR importing: %@", error.localizedDescription]);
        return NO;
    }
}

void printUsage() {
    printMsg(@"Usage:");
    printMsg(@"  ./contacts -d                   Delete ALL contacts");
    printMsg(@"  ./contacts -i <num1> <num2>...  Import specific numbers");
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printUsage();
            return 1;
        }
        
        NSString *flag = [NSString stringWithUTF8String:argv[1]];
        
        if ([flag isEqualToString:@"-d"]) {
            return deleteAllContacts() ? 0 : 1;
        } 
        else if ([flag isEqualToString:@"-i"]) {
            if (argc < 3) {
                printMsg(@"Error: Missing arguments for -i");
                printUsage();
                return 1;
            }
            NSMutableArray *numbers = [NSMutableArray array];
            for (int i = 2; i < argc; i++) {
                [numbers addObject:[NSString stringWithUTF8String:argv[i]]];
            }
            return importContacts(numbers) ? 0 : 1;
        } 
        else {
            printMsg([NSString stringWithFormat:@"Unknown flag: %@", flag]);
            printUsage();
            return 1;
        }
    }
    return 0;
}
