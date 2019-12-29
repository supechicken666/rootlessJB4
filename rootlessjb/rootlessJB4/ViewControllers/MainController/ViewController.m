//
//  ViewController.m
//  rootlessJB4
//
//  Created by Brandon Plank on 8/28/19.
//  Copyright © 2019 Brandon Plank. All rights reserved.
//

#import "ViewController.h"
#include "everythingElse.h"
#include "insert_dylib.h"

#include "jelbrekLib.h"
#include "libjb.h"
#include "payload.h"

#import <mach/mach.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <dlfcn.h>
#include "vnode.h"
#include "offsetsDump.h"

#define LOG(string, args...) do {\
printf(string "\n", ##args); \
} while (0)


#define in_bundle(obj) strdup([[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@obj] UTF8String])

#define failIf(condition, message, ...) if (condition) {\
}

#define maxVersion(v)  ([[[UIDevice currentDevice] systemVersion] compare:@v options:NSNumericSearch] != NSOrderedDescending)


#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]

#define removeFile(file) if (fileExists(file)) {\
[[NSFileManager defaultManager]  removeItemAtPath:@(file) error:NULL]; \
}


#define copyFile(copyFrom, copyTo) [[NSFileManager defaultManager] copyItemAtPath:@(copyFrom) toPath:@(copyTo) error:NULL]; \

#define moveFile(copyFrom, moveTo) [[NSFileManager defaultManager] moveItemAtPath:@(copyFrom) toPath:@(moveTo) error:NULL]; \




@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *jbtext;
@property (weak, nonatomic) IBOutlet UIButton *unjbtext;
@property (weak, nonatomic) IBOutlet UISwitch *tweaks;
@property (weak, nonatomic) IBOutlet UISwitch *filza;
@property (weak, nonatomic) IBOutlet UISwitch *ReProvision;
@property (weak, nonatomic) IBOutlet UISwitch *saily;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exploitControl;


@end

@implementation ViewController

struct utsname u;
vm_size_t psize;
int csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize);



BOOL debug = true;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    uint32_t flags;
    csops(getpid(), 0, &flags, 0);
    
    if ((flags & 0x4000000)) { // platform
        [self.jbtext setTitle:@"Jailbroken" forState:UIControlStateNormal];
        [self.jbtext setEnabled:NO];
    }
    
    uname(&u);
    if (strstr(u.machine, "iPad5,")) psize = 0x1000;
    else _host_page_size(mach_host_self(), &psize);
}


- (void)resignAndInjectToTrustCache:(NSString *)path ents:(NSString *)ents
{
    ents = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/data/ents/entitlements_%@", ents];
    NSString *p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent %@ %@", ents, path];
    char *p_ = (char *)[p UTF8String];
    system_(p_);
    
    
    p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/bin/inject %@", path];
    char *pp_ = (char *)[p UTF8String];
    system_(pp_);
    
    printf("[S] %s\n", p_);
}

- (void)resignAndInjectToTrustCacheSaily:(NSString *)path ents:(NSString *)ents
{
    
    printf("[-] Do not install Saily.app in the jailbreak process.\n[-] Dylib and frameworks should not be able to local sign.\n[-] And they do not call fixmMap in their load process.\n");
    
//    ents = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/Applications/Saily.app/%@", ents];
//    NSString *p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent %@ %@", ents, path];
//    char *p_ = (char *)[p UTF8String];
//    system_(p_);
//
//    p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/bin/inject %@", path];
//    char *pp_ = (char *)[p UTF8String];
//    system_(pp_);
//
//    printf("[S] %s\n", p_);
}

- (IBAction)jailbreak:(id)sender {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 1/12"
                           forState:UIControlStateNormal];
            
        });
        
        // MARK: EXPLOIT
        runExploit((__bridge void *)(self));
        
        escapeSandbox();
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 2/12" forState:UIControlStateNormal];
            
        });
        
        
        init_with_kbase(tfp0, kernel_base);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 3/12" forState:UIControlStateNormal];
            
        });
        
        rootify(getpid());
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 4/12" forState:UIControlStateNormal];
            
        });
        
        
        setHSP4();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 5/12" forState:UIControlStateNormal];
            
        });
        
        
        setcsflags(getpid()); // set some csflags
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 6/12" forState:UIControlStateNormal];
            
        });
        
        
        platformize(getpid()); // set TF_PLATFORM
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 7/12" forState:UIControlStateNormal];
            
        });
        
        
        UnlockNVRAM();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 8/12" forState:UIControlStateNormal];
            
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 9/12" forState:UIControlStateNormal];
            
        });
        
        
        // MARK: BOOTSTRAP
        if (!fileExists("/var/containers/Bundle/.installed_rootlessJB3")) {
            
            if (fileExists("/var/containers/Bundle/iosbinpack64")) {
                
                LOG("[*] Uninstalling previous build...");
                
                removeFile("/var/LIB");
                removeFile("/var/ulb");
                removeFile("/var/bin");
                removeFile("/var/sbin");
                removeFile("/var/containers/Bundle/tweaksupport/Applications");
                removeFile("/var/Apps");
                removeFile("/var/profile");
                removeFile("/var/motd");
                removeFile("/var/dropbear");
                removeFile("/var/containers/Bundle/tweaksupport");
                removeFile("/var/containers/Bundle/iosbinpack64");
                removeFile("/var/containers/Bundle/dylibs");
                removeFile("/var/log/testbin.log");
                
                if (fileExists("/var/log/jailbreakd-stdout.log")) removeFile("/var/log/jailbreakd-stdout.log");
                if (fileExists("/var/log/jailbreakd-stderr.log")) removeFile("/var/log/jailbreakd-stderr.log");
            }
            
            LOG("[*] Installing bootstrap...");
            
            chdir("/var/containers/Bundle/");
            FILE *bootstrap = fopen((char*)in_bundle("tars/iosbinpack.tar"), "r");
            untar(bootstrap, "/var/containers/Bundle/");
            fclose(bootstrap);
            
            FILE *tweaks = fopen((char*)in_bundle("tars/tweaksupport.tar"), "r");
            untar(tweaks, "/var/containers/Bundle/");
            fclose(tweaks);
            
            failIf(!fileExists("/var/containers/Bundle/tweaksupport") || !fileExists("/var/containers/Bundle/iosbinpack64"), "[-] Failed to install bootstrap");
            
            LOG("[+] Creating symlinks...");
            
            symlink("/var/containers/Bundle/tweaksupport/Library", "/var/LIB");
            symlink("/var/containers/Bundle/tweaksupport/usr/lib", "/var/ulb");
            symlink("/var/containers/Bundle/tweaksupport/Applications", "/var/Apps");
            symlink("/var/containers/Bundle/tweaksupport/bin", "/var/bin");
            symlink("/var/containers/Bundle/tweaksupport/sbin", "/var/sbin");
            symlink("/var/containers/Bundle/tweaksupport/usr/libexec", "/var/libexec");
            
            close(open("/var/containers/Bundle/.installed_rootlessJB3", O_CREAT));
            
            //limneos
            symlink("/var/containers/Bundle/iosbinpack64/etc", "/var/etc");
            symlink("/var/containers/Bundle/tweaksupport/usr", "/var/usr");
            symlink("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "/var/bin/killall");
            
            LOG("[+] Installed bootstrap!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"-> 10/12" forState:UIControlStateNormal];
                
            });
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 11/12" forState:UIControlStateNormal];
            
        });
        
        
        // MARK: JBDaemon
        //---- for jailbreakd & amfid ----//
        failIf(dumpOffsetsToFile("/var/containers/Bundle/tweaksupport/offsets.data"), "[-] Failed to save offsets");
        
        //---- different tools ----//
        
        if (!fileExists("/var/bin/strings")) {
            chdir("/");
            FILE *essentials = fopen((char*)in_bundle("tars/bintools.tar"), "r");
            untar(essentials, "/");
            fclose(essentials);
            
            FILE *dpkg = fopen((char*)in_bundle("tars/dpkg-rootless.tar"), "r");
            untar(dpkg, "/");
            fclose(dpkg);
        }
        
        // MARK: OPENSSH
        //---- update dropbear ----//
        chdir("/var/containers/Bundle/");
        
        removeFile("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear");
        removeFile("/var/containers/Bundle/iosbinpack64/usr/bin/scp");
        
        FILE *fixed_dropbear = fopen((char*)in_bundle("tars/dropbear.v2018.76.tar"), "r");
        untar(fixed_dropbear, "/var/containers/Bundle/");
        fclose(fixed_dropbear);
        
        //---- update jailbreakd ----//
        // MARK: JBDaemon Update
        removeFile("/var/containers/Bundle/iosbinpack64/bin/jailbreakd");
        if (!fileExists(in_bundle("bins/jailbreakd"))) {
            chdir(in_bundle("bins/"));
            
            FILE *jbd = fopen(in_bundle("bins/jailbreakd.tar"), "r");
            untar(jbd, in_bundle("bins/jailbreakd"));
            fclose(jbd);
            
            removeFile(in_bundle("bins/jailbreakd.tar"));
        }
        copyFile(in_bundle("bins/jailbreakd"), "/var/containers/Bundle/iosbinpack64/bin/jailbreakd");
        
        removeFile("/var/containers/Bundle/iosbinpack64/pspawn.dylib");
        if (!fileExists(in_bundle("bins/pspawn.dylib"))) {
            chdir(in_bundle("bins/"));
            
            FILE *jbd = fopen(in_bundle("bins/pspawn.dylib.tar"), "r");
            untar(jbd, in_bundle("bins/pspawn.dylib"));
            fclose(jbd);
            
            removeFile(in_bundle("bins/pspawn.dylib.tar"));
        }
        copyFile(in_bundle("bins/pspawn.dylib"), "/var/containers/Bundle/iosbinpack64/pspawn.dylib");
        
        removeFile("/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");
        if (!fileExists(in_bundle("bins/amfid_payload.dylib"))) {
            chdir(in_bundle("bins/"));
            
            FILE *jbd = fopen(in_bundle("bins/amfid_payload.dylib.tar"), "r");
            untar(jbd, in_bundle("bins/amfid_payload.dylib"));
            fclose(jbd);
            
            removeFile(in_bundle("bins/amfid_payload.dylib.tar"));
        }
        copyFile(in_bundle("bins/amfid_payload.dylib"), "/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");
        
        removeFile("/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
        if (!fileExists(in_bundle("bins/TweakInject.dylib"))) {
            chdir(in_bundle("bins/"));
            
            FILE *jbd = fopen(in_bundle("bins/TweakInject.tar"), "r");
            untar(jbd, in_bundle("bins/TweakInject.dylib"));
            fclose(jbd);
            
            removeFile(in_bundle("bins/TweakInject.tar"));
        }
        copyFile(in_bundle("bins/TweakInject.dylib"), "/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
        
        removeFile("/var/log/pspawn_payload_xpcproxy.log");
        
        //---- codesign patch ----//
        // MARK: CODESIGN
        if (!fileExists(in_bundle("bins/tester"))) {
            chdir(in_bundle("bins/"));
            
            FILE *f1 = fopen(in_bundle("bins/tester.tar"), "r");
            untar(f1, in_bundle("bins/tester"));
            fclose(f1);
            
            removeFile(in_bundle("bins/tester.tar"));
        }
        
        chmod(in_bundle("bins/tester"), 0777); // give it proper permissions
        
        if (launch(in_bundle("bins/tester"), NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
            failIf(trustbin("/var/containers/Bundle/iosbinpack64"), "[-] Failed to trust binaries!");
            failIf(trustbin("/var/containers/Bundle/tweaksupport"), "[-] Failed to trust binaries!");
            
            // test
            int ret = launch("/var/containers/Bundle/iosbinpack64/test", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
            failIf(ret, "[-] Failed to trust binaries!");
            LOG("[+] Successfully trusted binaries!");
        }
        else {
            LOG("[+] binaries already trusted?");
        }
        
        //---- let's go! ----//
        
        prepare_payload(); // this will chmod 777 everything
        
        // MARK: SETUP
        //----- setup SSH -----//
        mkdir("/var/dropbear", 0777);
        removeFile("/var/profile");
        removeFile("/var/motd");
        chmod("/var/profile", 0777);
        chmod("/var/motd", 0777);
        
        copyFile("/var/containers/Bundle/iosbinpack64/etc/profile", "/var/profile");
        copyFile("/var/containers/Bundle/iosbinpack64/etc/motd", "/var/motd");
        
        // kill it if running
        launch("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "-SEGV", "dropbear", NULL, NULL, NULL, NULL, NULL);
        failIf(launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL), "[-] Failed to launch dropbear");
        pid_t dpd = pid_of_procName("dropbear");
        usleep(1000);
        if (!dpd) failIf(launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL), "[-] Failed to launch dropbear");
        
        //------------- launch daeamons -------------//
        //-- you can drop any daemon plist in iosbinpack64/LaunchDaemons and it will be loaded automatically --//
        
        plists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/containers/Bundle/iosbinpack64/LaunchDaemons" error:nil];
        
        for (__strong NSString *file in plists) {
            printf("[*] Adding permissions to plist %s\n", [file UTF8String]);
            
            file = [@"/var/containers/Bundle/iosbinpack64/LaunchDaemons" stringByAppendingPathComponent:file];
            
            if (strstr([file UTF8String], "jailbreakd")) {
                printf("[*] Found jailbreakd plist, special handling\n");
                
                NSMutableDictionary *job = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:file] options:NSPropertyListMutableContainers format:nil error:nil];
                
                job[@"EnvironmentVariables"][@"KernelBase"] = [NSString stringWithFormat:@"0x%16llx", KernelBase];
                [job writeToFile:file atomically:YES];
            }
            
            chmod([file UTF8String], 0644);
            chown([file UTF8String], 0, 0);
        }
        
        // clean up
        removeFile("/var/log/testbin.log");
        removeFile("/var/log/jailbreakd-stderr.log");
        removeFile("/var/log/jailbreakd-stdout.log");
        
        launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "unload", "/var/containers/Bundle/iosbinpack64/LaunchDaemons", NULL, NULL, NULL, NULL, NULL);
        launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "load", "/var/containers/Bundle/iosbinpack64/LaunchDaemons", NULL, NULL, NULL, NULL, NULL);
        
        sleep(1);
        
        failIf(!fileExists("/var/log/testbin.log"), "[-] Failed to load launch daemons");
        failIf(!fileExists("/var/log/jailbreakd-stdout.log"), "[-] Failed to load jailbreakd");
        
        if (!fileExists("/var/containers/Bundle/tweaksupport/data/ents"))
        {
            if (fileExists(in_bundle("tars/ents.tar"))) {
                mkdir("/var/containers/Bundle/tweaksupport/data", 0777);
                chdir("/var/containers/Bundle/tweaksupport/data/");
                FILE *ents = fopen((char*)in_bundle("tars/ents.tar"), "r");
                untar(ents, "/var/containers/Bundle/tweaksupport/data/");
                fclose(ents);
            }
        }
        
        if (!fileExists("/var/containers/Bundle/tweaksupport/data/.installed_debs"))
        {
            NSString *debs_path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"debs"];
            NSArray *debs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:debs_path error:nil];
            for (NSString *deb in debs) {
                /* run dpkg -i */
                char *environ[] = {"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games:/var/containers/Bundle/iosbinpack64/usr/local/sbin:/var/containers/Bundle/iosbinpack64/usr/local/bin:/var/containers/Bundle/iosbinpack64/usr/sbin:/var/containers/Bundle/iosbinpack64/usr/bin:/var/containers/Bundle/iosbinpack64/sbin:/var/containers/Bundle/iosbinpack64/bin", NULL};
                launch("/var/bin/dpkg", "-i", (char *)[[debs_path stringByAppendingPathComponent:deb] UTF8String], NULL, NULL, NULL, NULL, (char **)environ);
            }
            close(open("/var/containers/Bundle/tweaksupport/data/.installed_debs", O_CREAT));
        }
        
        // MARK: INJECT TWEAK
        if (self.tweaks.isOn) {
            
            LOG("[*] Time for magic");
            
            char *xpcproxy = "/var/libexec/xpcproxy";
            char *dylib = "/var/ulb/pspawn.dylib";
            
            if (!fileExists(xpcproxy)) {
                bool cp = copyFile("/usr/libexec/xpcproxy", xpcproxy);
                failIf(!cp, "[-] Can't copy xpcproxy!");
                symlink("/var/containers/Bundle/iosbinpack64/pspawn.dylib", dylib);
                
                LOG("[*] Patching xpcproxy");
                
                const char *args[] = { "insert_dylib", "--all-yes", "--inplace", "--overwrite", dylib, xpcproxy, NULL};
                int argn = 6;
                
                failIf(add_dylib(argn, args), "[-] Failed to patch xpcproxy :(");
                
                LOG("[*] Resigning xpcproxy");
                
                failIf(system_("/var/containers/Bundle/iosbinpack64/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/iosbinpack64/default.ent /var/libexec/xpcproxy"), "[-] Failed to resign xpcproxy!");
            }
            
            chown(xpcproxy, 0, 0);
            chmod(xpcproxy, 755);
            failIf(trustbin(xpcproxy), "[-] Failed to trust xpcproxy!");
            
            uint64_t realxpc = getVnodeAtPath("/usr/libexec/xpcproxy");
            uint64_t fakexpc = getVnodeAtPath(xpcproxy);
            
            struct vnode rvp, fvp;
            KernelRead(realxpc, &rvp, sizeof(struct vnode));
            KernelRead(fakexpc, &fvp, sizeof(struct vnode));
            
            fvp.v_usecount = rvp.v_usecount;
            fvp.v_kusecount = rvp.v_kusecount;
            fvp.v_parent = rvp.v_parent;
            fvp.v_freelist = rvp.v_freelist;
            fvp.v_mntvnodes = rvp.v_mntvnodes;
            fvp.v_ncchildren = rvp.v_ncchildren;
            fvp.v_nclinks = rvp.v_nclinks;
            
            KernelWrite(realxpc, &fvp, sizeof(struct vnode)); // :o
            
            LOG("[?] Are we still alive?!");
            
            //----- magic end here -----//
            
            // cache pid and we're done
            pid_t installd = pid_of_procName("installd");
            pid_t bb = pid_of_procName("backboardd");
            pid_t amfid = pid_of_procName("amfid");
            if (amfid) kill(amfid, SIGKILL);
            
            // AppSync
            
            fixMmap("/var/ulb/libsubstitute.dylib");
            fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
            fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
            
            if (installd) kill(installd, SIGKILL);
            
            if (true) {
                /* Temporary fix uicache */
                launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                NSArray *invalidApps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/Apps" error:nil];
                for (NSString *app in invalidApps) {
                    NSString *path = [@"/var/Apps" stringByAppendingPathComponent:app];
                    removeFile([path UTF8String]);
                }
            }
            
            // MARK: INSTALL Reprovision
            if (self.ReProvision.isOn) {
                
                LOG("[*] Installing ReProvision");
                
                removeFile("/var/containers/Bundle/tweaksupport/Applications/ReProvision.app");
                copyFile(in_bundle("apps/ReProvision.app"), "/var/containers/Bundle/tweaksupport/Applications/ReProvision.app");
                
                failIf(system_("/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ent.xml /var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ReProvision && /var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ReProvision"), "[-] Failed to sign ReProvision");
                
                removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/ReProvision");
                copyFile("/var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ReProvision", "/var/LIB/MobileSubstrate/DynamicLibraries/ReProvision");
                
                // just in case
                fixMmap("/var/ulb/libsubstitute.dylib");
                fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                
                
                removeFile("/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.matchstic.reprovisiond.plist");
                removeFile("/var/containers/Bundle/tweaksupport/usr/bin/reprovisiond");
                
                copyFile(in_bundle("apps/com.matchstic.reprovisiond.plist"), "/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.matchstic.reprovisiond.plist");
                copyFile(in_bundle("apps/reprovisiond"), "/var/containers/Bundle/tweaksupport/usr/bin/reprovisiond");
                chmod("/var/containers/Bundle/tweaksupport/usr/bin/reprovisiond", 0777);
                
                //resign
                failIf(trustbin("/var/containers/Bundle/iosbinpack64/usr/bin/reprovisiond"), "[-] Failed to trust binaries!");
                
                
                //                failIf(launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL), "[-] Failed to install iSuperSU");
                
            }
            
            if(debug == true){
                
                
                LOG("[*] Debug mode is on!");
                
                LOG("[*] Installing iSuperSU");
                
                removeFile("/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
                copyFile(in_bundle("apps/iSuperSU.app"), "/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
                
                failIf(system_("/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/ent.xml /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU && /var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU"), "[-] Failed to sign iSuperSU");
                
                removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/iSuperSU");
                copyFile("/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU", "/var/LIB/MobileSubstrate/DynamicLibraries/iSuperSU");
                
                // just in case
                fixMmap("/var/ulb/libsubstitute.dylib");
                fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                
                
            }else{
                LOG("[*] Debug mode is off!");
                goto continue1;
                
                
            }
        continue1:
            
            // MARK: Install Saily.Daemon
            if (self.saily.isOn) {
//            if (false) {
                    
                dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WARNING"
                                                   message:@"Saily.app should be installed by your resign tools as well as rootless JB itself."
                                                   preferredStyle:UIAlertControllerStyleAlert];

                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                        dispatch_semaphore_signal(sem);
                    }];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:true completion: nil];
                    
                });
                
                dispatch_semaphore_wait(sem, 30);
                
                goto escapeSaily;
                
                LOG("[*] Installing RootlessInstaller");
                
                removeFile("/var/containers/Bundle/tweaksupport/Applications/Saily.app");
                copyFile(in_bundle("apps/Saily.app"), "/var/containers/Bundle/tweaksupport/Applications/Saily.app");
                
                failIf(system_("/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/tweaksupport/Applications/Saily.app/ent.xml /var/containers/Bundle/tweaksupport/Applications/Saily.app/Saily && /var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/Saily.app/Saily"), "[-] Failed to sign Saily.app");
                
                removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/Saily");
                copyFile("/var/containers/Bundle/tweaksupport/Applications/Saily.app/Saily", "/var/LIB/MobileSubstrate/DynamicLibraries/Saily.app");
                
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/Applications/Saily.app/Saily" ents:@"ent.xml"];

                // just in case
                fixMmap("/var/ulb/libsubstitute.dylib");
                fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                
                // The frameworks under Saily also need to be resigned, but its too f*** just use impactor?
                
                failIf(launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL), "[-] Failed to install Saily.app");
                
            }
        escapeSaily:
            
            // MARK: Install Filza
            if (self.filza.isOn){
                
                LOG("[*] Installing Filza File Manager");
                if (!fileExists("/var/libexec"))
                {
                    symlink("/var/containers/Bundle/tweaksupport/usr/libexec", "/var/libexec");
                }
                mkdir("/var/containers/Bundle/tweaksupport/usr/libexec/filza", 0777);
                chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza", 0, 0);
                chown("/var/mobile/Library/Filza/.Trash", 501, 501);
                chown("/var/mobile/Library/Filza/.Trash.metadata", 501, 501);
                chown("/var/root/Library/Filza/extensions.plist", 501, 501);
                chown("/var/root/Library/Filza/links.plist", 501, 501);
                chown("/var/root/Library/Filza/filza.db", 501, 501);
                chown("/var/root/Library/Preferences/com.tigisoftware.Filza.plist", 501, 501);
                
                removeFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app");
                removeFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza");
                removeFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper");
                removeFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer");
                removeFile("/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.tigisoftware.filza.helper.plist");
                removeFile("/var/mobile/Library/Caches/ImageTables");
                unlink("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza");
                
                if (fileExists(in_bundle("apps/Filza.app.tar"))) {
                    chdir("/var/containers/Bundle/tweaksupport/Applications/");
                    FILE *app = fopen((char*)in_bundle("apps/Filza.app.tar"), "r");
                    untar(app, "/var/containers/Bundle/tweaksupport/Applications/");
                    fclose(app);
                }
                
                copyFile(in_bundle("tars/com.tigisoftware.filza.helper.plist"), "/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.tigisoftware.filza.helper.plist");
                
                chown("/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.tigisoftware.filza.helper.plist", 0, 0);
                
                if (fileExists(in_bundle("bins/FilzaBins.tar"))) {
                    chdir("/var/containers/Bundle/tweaksupport/usr/libexec/filza/");
                    FILE *f1 = fopen(in_bundle("bins/FilzaBins.tar"), "r");
                    untar(f1, "/var/containers/Bundle/tweaksupport/usr/libexec/filza/");
                    fclose(f1);
                    
                    chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza", 0, 0);
                    chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper", 0, 0);
                    chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer", 0, 0);
                    NSUInteger perm = S_ISUID | S_ISGID | S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH;
                    chmod("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza", perm);
                    chmod("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper", 0777);
                    chmod("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer", 0777);
                }
                moveFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing", "/var/containers/Bundle/tweaksupport/usr/libexec/filza/Sharing");
                symlink("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza", "/var/bin/Filza");
                
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza" ents:@"platform.xml"];
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper" ents:@"platform.xml"];
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer" ents:@"platform.xml"];
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/Applications/Filza.app/Filza" ents:@"filza.xml"];
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/Applications/Filza.app/dylibs/libsmb2-ios.dylib" ents:@"dylib.xml"];
                [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/Sharing" ents:@"appex.xml"];
                moveFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Sharing", "/var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing");
                system_("/var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing");
                
                launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "unload", "/var/containers/Bundle/iosbinpack64/LaunchDaemons/com.tigisoftware.filza.helper.plist", NULL, NULL, NULL, NULL, NULL);
                
                launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "load", "-w", "/var/containers/Bundle/iosbinpack64/LaunchDaemons/com.tigisoftware.filza.helper.plist", NULL, NULL, NULL, NULL);
                
                mkdir("/var/containers/Bundle/tweaksupport/data", 0777);
                removeFile("/var/containers/Bundle/tweaksupport/data/Filza.app");
                copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app", "/var/containers/Bundle/tweaksupport/data/Filza.app");
                
                removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/Filza");
                removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/Sharing");
                removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/libsmb2-ios.dylib");
                
                copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/Filza", "/var/LIB/MobileSubstrate/DynamicLibraries/Filza");
                copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing", "/var/LIB/MobileSubstrate/DynamicLibraries/Sharing");
                copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/dylibs/libsmb2-ios.dylib", "/var/LIB/MobileSubstrate/DynamicLibraries/libsmb2-ios.dylib");
                
                // just in case
                fixMmap("/var/ulb/libsubstitute.dylib");
                fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                
                failIf(launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL), "[-] Failed to install Filza File Manager");
                
            }
            
            
            
            NSArray *tweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/ulb/TweakInject" error:NULL];
            for (NSString *afile in tweaks) {
                if ([afile hasSuffix:@"plist"]) {
                    
                    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/ulb/TweakInject/%@",afile]];
                    NSString *dylibPath = [afile stringByReplacingOccurrencesOfString:@".plist" withString:@".dylib"];
                    fixMmap((char *)[[NSString stringWithFormat:@"/var/ulb/TweakInject/%@", dylibPath] UTF8String]);
                    NSArray *executables = [[plist objectForKey:@"Filter"] objectForKey:@"Executables"];
                    
                    for (NSString *processName in executables) {
                        if (![processName isEqual:@"SpringBoard"] && ![processName isEqual:@"backboardd"] && ![processName isEqual:@"assertiond"] && ![processName isEqual:@"launchd"]) { //really?
                            int procpid = pid_of_procName((char *)[processName UTF8String]);
                            if (procpid) {
                                kill(procpid, SIGKILL);
                            }
                        }
                    }
                    
                    NSArray *bundles = [[plist objectForKey:@"Filter"] objectForKey:@"Bundles"];
                    for (NSString *bundleID in bundles) {
                        if (![bundleID isEqual:@"com.apple.springboard"] && ![bundleID isEqual:@"com.apple.backboardd"] && ![bundleID isEqual:@"com.apple.assertiond"] && ![bundleID isEqual:@"com.apple.launchd"]) {
                            NSString *processName = [bundleID stringByReplacingOccurrencesOfString:@"com.apple." withString:@""];
                            int procpid = pid_of_procName((char *)[processName UTF8String]);
                            if (procpid) {
                                kill(procpid, SIGKILL);
                            }
                        }
                        
                    }
                }
            }
            
            // find which applications are jailbreak applications and inject their executable
            NSArray *applications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/containers/Bundle/Application/" error:NULL];
            
            for (NSString *string in applications) {
                NSString *fullPath = [@"/var/containers/Bundle/Application/" stringByAppendingString:string];
                NSArray *innerContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:NULL];
                for (NSString *innerFile in innerContents) {
                    if ([innerFile hasSuffix:@"app"]) {
                        
                        NSString *fullAppBundlePath = [fullPath stringByAppendingString:[NSString stringWithFormat:@"/%@",innerFile]];
                        NSString *_CodeSignature = [fullPath stringByAppendingString:[NSString stringWithFormat:@"/%@/_CodeSignature",innerFile]];
                        
                        NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist",fullAppBundlePath]];
                        NSString *executable = [infoPlist objectForKey:@"CFBundleExecutable"];
                        NSString *BuildMachineOSBuild = [infoPlist objectForKey:@"BuildMachineOSBuild"];
                        BOOL hasDTCompilerRelatedKeys=NO;
                        for (NSString *KEY in [infoPlist allKeys]) {
                            if ([KEY rangeOfString:@"DT"].location==0) {
                                hasDTCompilerRelatedKeys=YES;
                                break;
                            }
                        }
                        // check for keys added by native/appstore apps and exclude (theos and friends don't add BuildMachineOSBuild and DT_ on apps :-D )
                        // Xcode-added apps set CFBundleExecutable=Executable, exclude them too
                        
                        executable = [NSString stringWithFormat:@"%@/%@", fullAppBundlePath, executable];
                        
                        if (([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/.jb",fullAppBundlePath]] || ![[NSFileManager defaultManager] fileExistsAtPath:_CodeSignature] || (executable && ![executable isEqual:@"Executable"] && !BuildMachineOSBuild & !hasDTCompilerRelatedKeys)) && fileExists([executable UTF8String])) {
                            
                            LOG("Injecting executable %s",[executable UTF8String]);
                            system_((char *)[[NSString stringWithFormat:@"/var/containers/Bundle/iosbinpack64/usr/bin/inject %s", [executable UTF8String]] UTF8String]);
                        }
                        
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"Done!" forState:UIControlStateNormal];
                
            });
            
            
            LOG("[+] Really jailbroken!");
            term_jelbrek();
            
            // bye bye
            kill(bb, 9);
            //launch("/var/containers/Bundle/iosbinpack64/bin/bash", "-c", "/var/containers/Bundle/iosbinpack64/usr/bin/nohup /var/containers/Bundle/iosbinpack64/bin/bash -c \"/var/containers/Bundle/iosbinpack64/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.backboardd.plist && /var/containers/Bundle/iosbinpack64/usr/bin/ldrestart; /var/containers/Bundle/iosbinpack64/bin/launchctl load /System/Library/LaunchDaemons/com.apple.backboardd.plist\" 2>&1 >/dev/null &", NULL, NULL, NULL, NULL, NULL);
            exit(0);
            
            
            
        }
        
        
    });
}



int system_(char *cmd) {
    return launch("/var/bin/bash", "-c", cmd, NULL, NULL, NULL, NULL, NULL);
}


NSError *error = NULL;
NSArray *plists;



- (int)extracted {
    return setHSP4();
}

- (IBAction)uninstall:(id)sender {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"-> 1/3"
             
                            forState:UIControlStateNormal];
            
        });
        
        
                // MARK: EXPLOIT
        runExploit((__bridge void *)(self));
        
        escapeSandbox();
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_jbtext setTitle:@"-> 2/12" forState:UIControlStateNormal];
            
        });
        
        
        init_with_kbase(tfp0, kernel_base);
        
        
        
        unsandbox(getpid());
        printf("Unsandboxed");
        
        rootify(getpid());
        printf("rooted");
        
        setHSP4();
        
        [self extracted];
        
        setcsflags(getpid()); // set some csflags
        platformize(getpid()); // set TF_PLATFORM
        
        LOG("[*] Uninstalling...");
        
        // Just fucking do this
        //failIf(!fileExists("/var/containers/Bundle/.installed_rootlessJB4"), "[-] rootlessJB was never installed before! (this version of it)");
        
        removeFile("/var/LIB");
        removeFile("/var/ulb");
        removeFile("/var/bin");
        removeFile("/var/sbin");
        removeFile("/var/libexec");
        removeFile("/var/containers/Bundle/tweaksupport/Applications");
        removeFile("/var/Apps");
        removeFile("/var/profile");
        removeFile("/var/motd");
        removeFile("/var/dropbear");
        //removeFile("/var/containers/Bundle/tweaksupport");
        //removeFile("/var/containers/Bundle/iosbinpack64");
        removeFile("/var/log/testbin.log");
        removeFile("/var/log/jailbreakd-stdout.log");
        removeFile("/var/log/jailbreakd-stderr.log");
        removeFile("/var/log/pspawn_payload_xpcproxy.log");
        removeFile("/var/containers/Bundle/.installed_rootlessJB3");
        removeFile("/var/lib");
        removeFile("/var/etc");
        removeFile("/var/usr");
        removeFile("/var/containers/Bundle/.installed_rootlessJB3")
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"-> 3/3" forState:UIControlStateNormal];
            
        });
        
        sleep(2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"-> Running uicache" forState:UIControlStateNormal];
            
        });
        
        launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        NSArray *invalidApps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/Apps" error:nil];
        for (NSString *app in invalidApps) {
            NSString *path = [@"/var/Apps" stringByAppendingPathComponent:app];
            removeFile([path UTF8String]);
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"-> Cleaning /var/bin" forState:UIControlStateNormal];
            
        });
        
        removeFile("/var/containers/Bundle/tweaksupport");
        removeFile("/var/containers/Bundle/iosbinpack64");
        
        term_jelbrek();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Finished."
             
                            forState:UIControlStateNormal];
            
        });
        
        sleep(5);
        exit(0);
        
    });
    
}


- (IBAction)credits:(id)sender {
    NSString *message = [NSString stringWithFormat:@"rootlessJB by Jake James\n\nMaintained by Brandon Plank(@BrandonD3V)\n\nSockPuppet exploit by Ned Williamson\n\nSockPort exploit by Jake James\n\nSockPuppet3 exploit by Umang Raghuvanshi\n\nKernel Base and kernel slide finder by @Chr0nicT\n\nSaily Package Manager by @Lakr233\n\nVersion RC.1.2"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Credits" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *Done = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:Done];
    [alertController setPreferredAction:Done];
    [self presentViewController:alertController animated:true completion:nil];
    
}


@end



